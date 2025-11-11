import 'package:flutter/material.dart';
import '../models/voiture.dart';
import '../models/categorie.dart';
import '../services/api_service.dart';
import '../widgets/voiture_card.dart';
import 'voiture_add_screen.dart';
import 'voiture_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Categorie> categories = [];
  List<Voiture> allVoitures = [];
  List<Voiture> filteredVoitures = [];
  final ApiService api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    loadData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _filterVoitures(_searchController.text);
  }

  void _filterVoitures(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredVoitures = allVoitures;
      } else {
        filteredVoitures = allVoitures.where((voiture) {
          final marque = voiture.marque.toLowerCase();
          final modele = voiture.modele.toLowerCase();
          final searchLower = query.toLowerCase();
          return marque.contains(searchLower) || modele.contains(searchLower);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      filteredVoitures = allVoitures;
    });
  }

  void loadData() async {
    final categoriesData = await api.getCategories();
    final voituresData = await api.getVoitures();
    setState(() {
      categories = categoriesData;
      allVoitures = voituresData;
      filteredVoitures = voituresData;
    });
    _tabController = TabController(
      length: categories.length + 1,
      vsync: this,
    );
  }

  List<Voiture> getVoituresByCategory(int categoryIndex) {
    final voituresToUse = _isSearching ? filteredVoitures : allVoitures;
    if (categoryIndex == 0) return voituresToUse;
    final category = categories[categoryIndex - 1];
    return voituresToUse.where((voiture) => voiture.categorie.id == category.id).toList();
  }

  void navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VoitureAddScreen()),
    );
    if (result == true) loadData();
  }

  void navigateToEdit(Voiture v) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VoitureEditScreen(voiture: v)),
    );
    if (result == true) loadData();
  }

  void deleteVoiture(int id) async {
    await api.deleteVoiture(id);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClair,
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : const Text(
          'RentEase',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        actions: _buildAppBarActions(),
      ),
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (!_isSearching) _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllCarsTab(),
                ...categories.map((category) => _buildCategoryTab(category)).toList(),
              ],
            ),
          ),

          // Bouton placé juste au-dessus de la TabBar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton(
              onPressed: navigateToAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: jaune,
                foregroundColor: violet,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Ajouter une voiture'),
            ),
          ),

          // TabBar en bas
          _buildBottomTabBar(),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          onPressed: _clearSearch,
          icon: const Icon(Icons.close),
          tooltip: 'Annuler la recherche',
        ),
      ];
    } else {
      return [
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
          icon: const Icon(Icons.search),
          tooltip: 'Rechercher',
        ),
        const SizedBox(width: 8),
      ];
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Rechercher par marque ou modèle...',
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: _clearSearch,
        )
            : null,
      ),
      cursorColor: jaune,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: violet),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une voiture...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: violet),
                    onPressed: _clearSearch,
                  )
                      : null,
                ),
                onChanged: (value) {
                  _filterVoitures(value);
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTabBar() {
    return Container(
      color: violet,
      child: SafeArea(
        top: false,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            color: jaune,
            borderRadius: BorderRadius.circular(8),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: violet,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(icon: Icon(Icons.all_inclusive, size: 18), text: 'Toutes'),
            ...categories.map((category) {
              return Tab(
                icon: Icon(_getIconForCategory(category), size: 18),
                text: category.nom,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(Categorie category) {
    switch (category.nom.toLowerCase()) {
      case 'economique':
        return Icons.attach_money;
      case 'luxe':
        return Icons.diamond_outlined;
      case 'suv':
        return Icons.local_shipping;
      case 'berline':
        return Icons.directions_car;
      case 'citadine':
        return Icons.electric_car;
      default:
        return Icons.directions_car;
    }
  }

  Widget _buildAllCarsTab() {
    final voituresToShow = _isSearching ? filteredVoitures : allVoitures;
    if (voituresToShow.isEmpty) {
      return _buildEmptyState(
        icon: Icons.car_rental,
        message: _isSearching ? 'Aucune voiture trouvée' : 'Aucune voiture disponible',
        subtitle: _isSearching
            ? 'Aucun résultat pour "${_searchController.text}"'
            : 'Ajoutez votre première voiture avec le bouton + !',
      );
    }
    return _buildVoituresGrid(voituresToShow);
  }

  Widget _buildCategoryTab(Categorie category) {
    final categoryVoitures = getVoituresByCategory(categories.indexOf(category) + 1);
    if (categoryVoitures.isEmpty) {
      return _buildEmptyState(
        icon: Icons.directions_car_outlined,
        message: _isSearching ? 'Aucune voiture trouvée dans ${category.nom}' : 'Aucune voiture dans ${category.nom}',
        subtitle: _isSearching
            ? 'Aucun résultat pour "${_searchController.text}" dans ${category.nom}'
            : 'Ajoutez une voiture de type ${category.nom}',
      );
    }
    return _buildVoituresGrid(categoryVoitures);
  }

  Widget _buildEmptyState({required IconData icon, required String message, required String subtitle}) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: violetClair),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(color: violet, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  subtitle,
                  style: TextStyle(color: violet.withOpacity(0.7), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_isSearching) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _clearSearch,
                  style: ElevatedButton.styleFrom(backgroundColor: violet, foregroundColor: jaune),
                  child: const Text('Effacer la recherche'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoituresGrid(List<Voiture> voitures) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: voitures.length,
        itemBuilder: (context, index) {
          final voiture = voitures[index];
          return VoitureCard(
            voiture: voiture,
            onEdit: () => navigateToEdit(voiture),
            onDelete: () => deleteVoiture(voiture.id!),
            primaryColor: violet,
            secondaryColor: violetClair,
            tertiaryColor: jaune,
          );
        },
      ),
    );
  }
}
