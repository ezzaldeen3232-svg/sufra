[11/25/1902 9:20 PM] 3zz El-din: import 'package:flutter/material.dart';

void main() {
  runApp(const SufraApp());
}

const orange = Color(0xFFFF6B35);
const navy = Color(0xFF17233C);

class SufraApp extends StatelessWidget {
  const SufraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'سُفرة',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: orange),
        scaffoldBackgroundColor: const Color(0xFFF7F7FA),
      ),
      home: const HomePage(),
    );
  }
}

class ServiceItem {
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final String category;

  const ServiceItem(
    this.name,
    this.description,
    this.price,
    this.icon,
    this.category,
  );
}

const products = <ServiceItem>[
  ServiceItem(
    'وجبة برجر',
    'برجر لذيذ مع البطاطس',
    145,
    Icons.lunch_dining,
    'مطاعم',
  ),
  ServiceItem(
    'بيتزا مارجريتا',
    'جبنة موزاريلا وطماطم',
    180,
    Icons.local_pizza,
    'مطاعم',
  ),
  ServiceItem(
    'قهوة لاتيه',
    'قهوة طازجة بالحليب',
    65,
    Icons.coffee,
    'مطاعم',
  ),
  ServiceItem(
    'خدمة سباكة',
    'صيانة منزلية تجريبية',
    200,
    Icons.plumbing,
    'خدمات',
  ),
  ServiceItem(
    'خدمة كهرباء',
    'صيانة الأعطال الكهربائية',
    250,
    Icons.electrical_services,
    'خدمات',
  ),
  ServiceItem(
    'تنظيف المنزل',
    'خدمة تنظيف منزلية',
    300,
    Icons.cleaning_services,
    'خدمات',
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String category = 'الكل';
  String search = '';
  final Map<String, int> cart = {};

  List<ServiceItem> get filteredProducts {
    return products.where((item) {
      final matchesCategory = category == 'الكل' ||
          (category == 'المطاعم' && item.category == 'مطاعم') ||
          (category == 'الخدمات' && item.category == 'خدمات');

      final query = search.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get count => cart.values.fold(0, (sum, value) => sum + value);

  int get total {
    return products.fold(
      0,
      (sum, item) => sum + item.price * (cart[item.name] ?? 0),
    );
  }

  void addItem(ServiceItem item) {
    setState(() {
      cart[item.name] = (cart[item.name] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${item.name} إلى السلة'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, refreshSheet) {
            final selected = products
                .where((item) => (cart[item.name] ?? 0) > 0)
                .toList();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'سلة سُفرة',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
[11/25/1902 9:20 PM] 3zz El-din: const SizedBox(height: 15),
                      if (selected.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('السلة فارغة، أضف بعض المنتجات أولًا'),
                        ),
                      ...selected.map(
                        (item) => ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.price} جنيه × ${cart[item.name]}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                final quantity = cart[item.name] ?? 0;
                                if (quantity <= 1) {
                                  cart.remove(item.name);
                                } else {
                                  cart[item.name] = quantity - 1;
                                }
                              });
                              refreshSheet(() {});
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الإجمالي',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$total جنيه',
                            style: const TextStyle(
                              fontSize: 20,
                              color: orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: orange,
                          ),
                          onPressed: selected.isEmpty
                              ? null
                              : () {
                                  final orderTotal = total;
                                  Navigator.pop(sheetContext);

                                  setState(() {
                                    cart.clear();
                                  });

                                  showDialog(
                                    context: this.context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('طلب تجريبي'),
                                      content: Text(
                                        'إجمالي طلبك $orderTotal جنيه. '
                                        'هذه تجربة فقط ولم يُرسل طلب حقيقي.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('حسنًا'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          child: const Text('تأكيد الطلب التجريبي'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
[11/25/1902 9:20 PM] 3zz El-din: @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.restaurant_menu, color: Color(0xFFFFB38F)),
              SizedBox(width: 9),
              Text(
                'سُفرة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: showCart,
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [navy, Color(0xFF344B73)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كل احتياجاتك في مكان واحد',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اطلب أكلك أو اختَر الخدمة المناسبة لك',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              onChanged: (value) => setState(() => search = value),
              decoration: InputDecoration(
                hintText: 'ابحث عن مطعم أو خدمة...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'استكشف سُفرة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _categoryButton('الكل', Icons.grid_view),
                const SizedBox(width: 8),
                _categoryButton('المطاعم', Icons.restaurant),
                const SizedBox(width: 8),
                _categoryButton(
                  'الخدمات',
                  Icons.home_repair_service,
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'اختيارات لك',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (filteredProducts.isEmpty)
              const Center(child: Text('لا توجد نتائج'))
            else
              ...filteredProducts.map(_productCard),
            const SizedBox(height: 80),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: orange,
          foregroundColor: Colors.white,
          onPressed: showCart,
          icon: const Icon(Icons.shopping_basket_outlined),
          label: Text('السلة ($count)'),
        ),
      ),
    );
  }

  Widget _categoryButton(String label, IconData icon) {
    final active = category == label;
[11/25/1902 9:20 PM] 3zz El-din: return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => category = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active ? orange : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? orange : const Color(0xFFE8E8ED),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: active ? Colors.white : navy),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCard(ServiceItem item) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 11),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: Color(0xFFEDEDF1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: orange.withOpacity(.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(item.icon, size: 31, color: orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.price} جنيه',
                    style: const TextStyle(
                      color: orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              tooltip: 'إضافة إلى السلة',
              style: IconButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () => addItem(item),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
