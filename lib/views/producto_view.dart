import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/producto_service.dart';

class ProductoView extends StatefulWidget {
  const ProductoView({super.key});

  @override
  State<ProductoView> createState() => _ProductoViewState();
}

class _ProductoViewState extends State<ProductoView> {
  List<Producto> productos = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _idCategoriaController = TextEditingController();
  final TextEditingController _idMarcaController = TextEditingController();
  final TextEditingController _idUnidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _idCategoriaController.dispose();
    _idMarcaController.dispose();
    _idUnidadController.dispose();
    super.dispose();
  }

  Future<void> _loadProductos() async {
    final data = await ProductoService.getProductos();
    setState(() {
      productos = data;
    });
  }

  Future<void> _mostrarDialogo({Producto? producto}) async {
    if (producto != null) {
      _nombreController.text = producto.nombre;
      _descripcionController.text = producto.descripcion;
      _idCategoriaController.text = producto.idCategoria.toString();
      _idMarcaController.text = producto.idMarca.toString();
      _idUnidadController.text = producto.idUnidadMedida.toString();
    } else {
      _nombreController.clear();
      _descripcionController.clear();
      _idCategoriaController.clear();
      _idMarcaController.clear();
      _idUnidadController.clear();
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
              TextField(
                controller: _idCategoriaController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'ID Categoría',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _idMarcaController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'ID Marca',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: _idUnidadController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'ID Unidad Medida',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final nombre = _nombreController.text.trim();
              final descripcion = _descripcionController.text.trim();
              final idCategoria = int.tryParse(_idCategoriaController.text.trim()) ?? 0;
              final idMarca = int.tryParse(_idMarcaController.text.trim()) ?? 0;
              final idUnidad = int.tryParse(_idUnidadController.text.trim()) ?? 0;

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
              _loadProductos();
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.purpleAccent)),
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
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar este producto?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ProductoService.deleteProducto(producto.idProducto);
      _loadProductos();
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
          return Card(
            color: const Color(0xFF1A033D),
            child: ListTile(
              title: Text(producto.nombre, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                'Descripción: ${producto.descripcion}\nCat: ${producto.idCategoria}, Marca: ${producto.idMarca}, Unidad: ${producto.idUnidadMedida}',
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