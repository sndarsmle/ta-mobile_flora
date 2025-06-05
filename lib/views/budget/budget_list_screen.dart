// lib/views/budget/budget_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:projekakhir_praktpm/presenters/budget_presenter.dart';
import 'package:projekakhir_praktpm/presenters/user_presenter.dart'; // Untuk mendapatkan currentUser
import 'package:projekakhir_praktpm/utils/constants.dart';

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  String? _currentUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dapatkan userId saat dependencies berubah (misalnya setelah login)
    // atau saat screen pertama kali dibangun.
    final userPresenter = Provider.of<UserPresenter>(context, listen: false);
    final newUserId = userPresenter.currentUser?.id;

    if (newUserId != null && newUserId != _currentUserId) {
      _currentUserId = newUserId;
      // Panggil loadBudgetItems dengan userId yang baru
      Provider.of<BudgetPresenter>(context, listen: false).loadBudgetItems(_currentUserId!);
    } else if (newUserId == null && _currentUserId != null) {
      // User logout, clear list
       _currentUserId = null;
       Provider.of<BudgetPresenter>(context, listen: false).loadBudgetItems(""); // Kirim empty string atau handle di presenter
    }
  }


  @override
  Widget build(BuildContext context) {
    // Untuk memastikan UI rebuild saat UserPresenter berubah (misalnya setelah login/logout)
    // kita bisa watch UserPresenter di sini, meskipun listen:false dipakai di didChangeDependencies
    // untuk pengambilan data awal.
    final userPresenter = context.watch<UserPresenter>(); 
    final currentUser = userPresenter.currentUser;

    if (currentUser == null) {
      // Tampilan jika user belum login
      return Scaffold(
        appBar: AppBar(
          title: const Text('Wishlist Budget Tanaman'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.mediumPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, size: 80, color: AppColors.hintColor),
                const SizedBox(height: AppPadding.mediumPadding),
                Text(
                  'Silakan login untuk melihat wishlist budget Anda.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.secondaryTextColor),
                ),
                const SizedBox(height: AppPadding.mediumPadding),
                ElevatedButton(
                    onPressed: (){
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                    child: const Text('Login Sekarang'),
                )
              ],
            ),
          ),
        ),
      );
    }

    // Jika sudah login, tampilkan list budget
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist Budget Tanaman'),
      ),
      body: Consumer<BudgetPresenter>(
        builder: (context, budgetPresenter, child) {
          // Pastikan budgetPresenter sudah load item untuk user saat ini
          // Pengecekan ulang di build mungkin diperlukan jika ada skenario kompleks,
          // tapi idealnya didChangeDependencies sudah handle.
          if (_currentUserId != currentUser.id) {
            // UserId berubah (misalnya baru login), panggil load lagi
             WidgetsBinding.instance.addPostFrameCallback((_) {
                if(mounted){ // Cek mounted untuk menghindari error setState setelah dispose
                   Provider.of<BudgetPresenter>(context, listen: false).loadBudgetItems(currentUser.id);
                   if(mounted) setState(() => _currentUserId = currentUser.id);
                }
             });
          }


          if (budgetPresenter.budgetItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.mediumPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.hintColor),
                    const SizedBox(height: AppPadding.mediumPadding),
                    Text(
                      'Wishlist budget Anda masih kosong.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.secondaryTextColor),
                    ),
                    const SizedBox(height: AppPadding.smallPadding),
                    Text(
                      'Simpan perkiraan harga tanaman dari halaman konversi.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hintColor),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppPadding.smallPadding),
            itemCount: budgetPresenter.budgetItems.length,
            itemBuilder: (context, index) {
              final item = budgetPresenter.budgetItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppPadding.smallPadding, horizontal: AppPadding.extraSmallPadding),
                color: AppColors.primaryColor.withOpacity(0.9),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppPadding.mediumPadding),
                  title: Text(
                    item.plantName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textColor),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppPadding.extraSmallPadding),
                      Text('Harga Asli: ${item.originalPriceIDR}', style: const TextStyle(color: AppColors.secondaryTextColor)),
                      Text('Konversi: ${item.convertedPrice} (${item.targetCurrency})', style: const TextStyle(color: AppColors.accentColor, fontWeight: FontWeight.w500)),
                      const SizedBox(height: AppPadding.extraSmallPadding),
                      Text(
                        'Disimpan pada: ${DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt)}', // Format tanggal diperbaiki
                        style: const TextStyle(color: AppColors.hintColor, fontSize: 10),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.dangerColor),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Item?'),
                          content: Text('Yakin ingin menghapus catatan budget untuk ${item.plantName}?'),
                          actions: [
                            TextButton(
                              child: const Text('Batal'),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            TextButton(
                              child: const Text('Hapus', style: TextStyle(color: AppColors.dangerColor)),
                              onPressed: () {
                                Provider.of<BudgetPresenter>(context, listen: false).removeBudgetItem(item.id, currentUser.id); // Kirim userId saat hapus
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Item budget dihapus.'), backgroundColor: AppColors.successColor),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}