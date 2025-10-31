import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../models/categoria_model.dart';
import '../models/marca_model.dart';
import '../models/unidad_medida_model.dart';
import '../services/producto_service.dart';
import '../services/categoria_service.dart';
import '../services/marca_service.dart';
import '../services/unidad_de_medida_service.dart';

class ProductoView extends StatefulWidget {
  const ProductoView({super.key});

  @override
  State<ProductoView> createState() => _ProductoViewState();
}

class _ProductoViewState extends State<ProductoView> {
  List<Producto> productos = [];
  List<Categoria> categorias = [];
  List<Marca> marcas = [];
  List<UnidadMedida> unidades = [];

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  Categoria? _categoriaSeleccionada;
  Marca? _marcaSeleccionada;
  UnidadMedida? _unidadSeleccionada;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prodData = await ProductoService.getProductos();
    final catData = await CategoriaService.getCategorias();
    final marData = await MarcaService.getMarcas();
    final uniData = await UnidadMedidaService.getUnidades();
    setState(() {
      productos = prodData;
      categorias = catData;
      marcas = marData;
      unidades = uniData;
    });
  }

  Future<void> _mostrarDialogo({Producto? producto}) async {
    if (producto != null) {
      _nombreController.text = producto.nombre;
      _descripcionController.text = producto.descripcion;
      _categoriaSeleccionada = categorias.firstWhere(
        (c) => c.id == producto.idCategoria,
        orElse: () => categorias.first,
      );
      _marcaSeleccionada = marcas.firstWhere(
        (m) => m.idMarca == producto.idMarca,
        orElse: () => marcas.first,
      );
      _unidadSeleccionada = unidades.firstWhere(
        (u) => u.idUnidad == producto.idUnidadMedida,
        orElse: () => unidades.first,
      );
    } else {
      _nombreController.clear();
      _descripcionController.clear();
      _categoriaSeleccionada = null;
      _marcaSeleccionada = null;
      _unidadSeleccionada = null;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: Text(
          producto == null ? 'Nuevo Producto' : 'Editar Producto',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _descripcionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Categoria>(
                initialValue: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF1A033D),
                ),
                dropdownColor: const Color(0xFF1A033D),
                style: const TextStyle(color: Colors.white),
                items: categorias
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c.nombre,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _categoriaSeleccionada = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Marca>(
                initialValue: _marcaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF1A033D),
                ),
                dropdownColor: const Color(0xFF1A033D),
                style: const TextStyle(color: Colors.white),
                items: marcas
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          m.nombre,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _marcaSeleccionada = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<UnidadMedida>(
                initialValue: _unidadSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Unidad Medida',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF1A033D),
                ),
                dropdownColor: const Color(0xFF1A033D),
                style: const TextStyle(color: Colors.white),
                items: unidades
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(
                          u.nombre,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _unidadSeleccionada = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              final nombre = _nombreController.text.trim();
              final descripcion = _descripcionController.text.trim();
              final idCategoria = _categoriaSeleccionada?.id ?? 0;
              final idMarca = _marcaSeleccionada?.idMarca ?? 0;
              final idUnidad = _unidadSeleccionada?.idUnidad ?? 0;

              if (nombre.isEmpty || descripcion.isEmpty) return;

              if (producto == null) {
                await ProductoService.createProducto(
                  Producto(
                    idProducto: 0,
                    nombre: nombre,
                    descripcion: descripcion,
                    idCategoria: idCategoria,
                    idMarca: idMarca,
                    idUnidadMedida: idUnidad,
                  ),
                );
              } else {
                producto.nombre = nombre;
                producto.descripcion = descripcion;
                producto.idCategoria = idCategoria;
                producto.idMarca = idMarca;
                producto.idUnidadMedida = idUnidad;
                await ProductoService.updateProducto(producto);
              }

              Navigator.pop(context);
              _loadData();
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.purpleAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF120321),
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Seguro que quieres eliminar este producto?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ProductoService.deleteProducto(producto.idProducto);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrincipal,
        title: const Text('Productos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          final nombreCategoria = categorias
              .firstWhere(
                (c) => c.id == producto.idCategoria,
                orElse: () => Categoria(id: 0, nombre: 'N/A'),
              )
              .nombre;
          final nombreMarca = marcas
              .firstWhere(
                (m) => m.idMarca == producto.idMarca,
                orElse: () => Marca(idMarca: 0, nombre: 'N/A'),
              )
              .nombre;
          final nombreUnidad = unidades
              .firstWhere(
                (u) => u.idUnidad == producto.idUnidadMedida,
                orElse: () => UnidadMedida(
                  idUnidad: 0,
                  nombre: 'N/A',
                  abreviacion: '',
                  tipoUnidad: '',
                ),
              )
              .nombre;

          return Card(
            color: const Color(0xFF1A033D),
            child: ListTile(
              title: Text(
                producto.nombre,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Descripción: ${producto.descripcion}\nCat: $nombreCategoria, Marca: $nombreMarca, Unidad: $nombreUnidad',
                style: const TextStyle(color: Colors.white70),
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () => _mostrarDialogo(producto: producto),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarEliminar(producto),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorPrincipal,
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogo(),
      ),
    );
  }
}
