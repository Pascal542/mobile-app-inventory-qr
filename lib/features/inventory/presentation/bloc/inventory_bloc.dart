import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/producto.dart';
import '../../services/firestore_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'dart:async';

/// Eventos del BLoC de inventario
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object> get props => [];
}

/// Evento para cargar los productos del usuario actual
class LoadProducts extends InventoryEvent {}

/// Evento para agregar un nuevo producto
class AddProduct extends InventoryEvent {
  final String nombre;
  final int cantidad;
  final String categoria;
  final double precio;

  const AddProduct({
    required this.nombre,
    required this.cantidad,
    required this.categoria,
    required this.precio,
  });

  @override
  List<Object> get props => [nombre, cantidad, categoria, precio];
}

/// Evento para actualizar un producto existente
class UpdateProduct extends InventoryEvent {
  final String productId;
  final String nuevoNombre;
  final int nuevaCantidad;
  final double nuevoPrecio;
  final String nuevaCategoria;

  const UpdateProduct({
    required this.productId,
    required this.nuevoNombre,
    required this.nuevaCantidad,
    required this.nuevoPrecio,
    required this.nuevaCategoria,
  });

  @override
  List<Object> get props => [productId, nuevoNombre, nuevaCantidad, nuevoPrecio, nuevaCategoria];
}

/// Evento para eliminar un producto
class DeleteProduct extends InventoryEvent {
  final String id;

  const DeleteProduct(this.id);

  @override
  List<Object> get props => [id];
}

/// Estados del BLoC de inventario
abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object> get props => [];
}

/// Estado inicial del inventario
class InventoryInitial extends InventoryState {}

/// Estado de carga del inventario
class InventoryLoading extends InventoryState {}

/// Estado cuando los productos han sido cargados exitosamente
class ProductsLoaded extends InventoryState {
  final List<Producto> products;

  const ProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

/// Estado cuando un producto ha sido agregado exitosamente
class ProductAdded extends InventoryState {
  final String productId;

  const ProductAdded(this.productId);

  @override
  List<Object> get props => [productId];
}

/// Estado cuando un producto ha sido actualizado exitosamente
class ProductUpdated extends InventoryState {
  final String productId;

  const ProductUpdated(this.productId);

  @override
  List<Object> get props => [productId];
}

/// Estado cuando un producto ha sido eliminado exitosamente
class ProductDeleted extends InventoryState {
  final String productId;

  const ProductDeleted(this.productId);

  @override
  List<Object> get props => [productId];
}

/// Estado de error en el inventario
class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object> get props => [message];
}

/// BLoC para manejar la lógica de negocio del inventario
/// 
/// Este BLoC maneja todas las operaciones relacionadas con productos:
/// - Cargar productos desde Firestore
/// - Agregar nuevos productos
/// - Actualizar productos existentes
/// - Eliminar productos
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final FirestoreService _firestoreService;
  final AuthBloc _authBloc;
  StreamSubscription? _authSubscription;
  String? _userId;

  /// Constructor del BLoC de inventario
  /// 
  /// [firestoreService] - Servicio para interactuar con Firestore
  /// [authBloc] - BLoC para manejar la autenticación del usuario
  InventoryBloc({
    required FirestoreService firestoreService,
    required AuthBloc authBloc,
  })  : _firestoreService = firestoreService,
        _authBloc = authBloc,
        super(InventoryInitial()) {
    
    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState is Authenticated) {
        _userId = authState.user.uid.split('_').last;
      } else {
        _userId = null;
      }
    });
    // Obtener estado inicial
    final initialState = _authBloc.state;
    if(initialState is Authenticated){
      _userId = initialState.user.uid.split('_').last;
    }

    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  /// Maneja el evento LoadProducts
  /// 
  /// Carga todos los productos desde Firestore y emite el estado correspondiente
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<InventoryState> emit,
  ) async {
    if (_userId == null) {
      emit(const InventoryError('Usuario no autenticado. No se pueden cargar productos.'));
      return;
    }
    try {
      emit(InventoryLoading());
      await emit.onEach<List<Producto>>(
        _firestoreService.obtenerProductos(_userId!),
        onData: (products) => emit(ProductsLoaded(products)),
        onError: (error, stackTrace) => emit(InventoryError('Error al cargar productos: $error')),
      );
    } catch (e) {
      emit(InventoryError('Error al cargar productos: $e'));
    }
  }

  /// Maneja el evento AddProduct
  /// 
  /// Agrega un nuevo producto a Firestore y emite el estado correspondiente
  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<InventoryState> emit,
  ) async {
    if (_userId == null) {
      emit(const InventoryError('Usuario no autenticado. No se puede agregar el producto.'));
      return;
    }
    try {
      emit(InventoryLoading());
      final productId = await _firestoreService.agregarProducto(
        _userId!,
        event.nombre,
        event.cantidad,
        event.categoria,
        event.precio,
      );
      emit(ProductAdded(productId));
    } catch (e) {
      emit(InventoryError('Error al agregar producto: $e'));
    }
  }

  /// Maneja el evento UpdateProduct
  /// 
  /// Actualiza un producto existente en Firestore y emite el estado correspondiente
  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<InventoryState> emit,
  ) async {
    if (_userId == null) {
      emit(const InventoryError('Usuario no autenticado. No se puede actualizar el producto.'));
      return;
    }
    try {
      emit(InventoryLoading());
      await _firestoreService.actualizarProducto(
        _userId!,
        event.productId,
        event.nuevoNombre,
        event.nuevaCantidad,
        event.nuevoPrecio,
        event.nuevaCategoria,
      );
      emit(ProductUpdated(event.productId));
    } catch (e) {
      emit(InventoryError('Error al actualizar producto: $e'));
    }
  }

  /// Maneja el evento DeleteProduct
  /// 
  /// Elimina un producto de Firestore y emite el estado correspondiente
  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<InventoryState> emit,
  ) async {
    if (_userId == null) {
      emit(const InventoryError('Usuario no autenticado. No se puede eliminar el producto.'));
      return;
    }
    try {
      emit(InventoryLoading());
      await _firestoreService.eliminarProducto(_userId!, event.id);
      emit(ProductDeleted(event.id));
    } catch (e) {
      emit(InventoryError('Error al eliminar producto: $e'));
    }
  }
} 