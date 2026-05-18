import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/text_recognition_service.dart';
import '../services/database_service.dart';
import '../models/food_model.dart';
import '../services/notification_service.dart';

class FridgeScreen extends StatefulWidget {
  final String searchQuery;

  const FridgeScreen({super.key, required this.searchQuery});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  final TextRecognitionService _recognitionService = TextRecognitionService();
  final DatabaseService _dbService = DatabaseService();
  final ImagePicker _picker = ImagePicker();

  late Future<List<FoodModel>> _foodListFuture;

  @override
  void initState() {
    super.initState();
    _refreshFoodList();
  }

  void _refreshFoodList() {
    setState(() {
      _foodListFuture = _dbService.getFoods();
    });
  }

  @override
  void dispose() {
    _recognitionService.dispose();
    super.dispose();
  }

  Future<bool?> _showDeleteDialog(String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("식재료 삭제"),
        content: Text("'$name'을(를) 삭제하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("아니요", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("네", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    bool tempAlarmOn = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("식재료 등록", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "식품 이름", hintText: "예: 우유, 계란"),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: "유통기한", hintText: "20260518"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () async {
                      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        String? detected = await _recognitionService.extractExpiryDate(image.path);
                        if (detected != null) {
                          String digits = detected.replaceAll(RegExp(r'[^0-9]'), '');
                          setDialogState(() => dateController.text = digits);
                        }
                      }
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.orange),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setDialogState(() => tempAlarmOn = !tempAlarmOn),
                  icon: Icon(
                    tempAlarmOn ? Icons.notifications_active : Icons.notifications_off,
                    color: tempAlarmOn ? Colors.orange : Colors.grey,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty && dateController.text.length >= 6) {
                      await _saveFood(nameController.text, dateController.text, tempAlarmOn);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("저장", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveFood(String name, String dateStr, bool alarmOn) async {
    try {
      String cleanDate = dateStr.replaceAll(RegExp(r'[^0-9]'), '');
      String formattedDate;

      if (cleanDate.length == 8) {
        formattedDate = "${cleanDate.substring(0, 4)}-${cleanDate.substring(4, 6)}-${cleanDate.substring(6, 8)}";
      } else if (cleanDate.length == 6) {
        formattedDate = "20${cleanDate.substring(0, 2)}-${cleanDate.substring(2, 4)}-${cleanDate.substring(4, 6)}";
      } else {
        throw const FormatException("날짜 자릿수가 부족합니다.");
      }

      DateTime expiry = DateTime.parse(formattedDate);

      // 1. DB 저장
      await _dbService.insertFood(FoodModel(
        name: name,
        expiryDate: expiry,
        isAlarmOn: alarmOn,
        category: '기타',
      ));

      // 2. 🔥 [수정] SharedPreferences에서 사용자가 설정한 알림 시간을 읽어서 반영
      if (alarmOn) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final hour = prefs.getInt('notificationHour') ?? 9;
          final minute = prefs.getInt('notificationMinute') ?? 0;

          // 유통기한 하루 전 날짜 계산
          final notificationDate = expiry.subtract(const Duration(days: 1));

          // 사용자가 설정한 시/분으로 알림 시간 구성
          DateTime scheduledAt = DateTime(
            notificationDate.year,
            notificationDate.month,
            notificationDate.day,
            hour,   // 🔥 설정값 반영
            minute, // 🔥 설정값 반영
          );

          // 설정한 시간이 이미 지났으면 5초 뒤에 즉시 알림 (테스트/당일 등록 대응)
          if (scheduledAt.isBefore(DateTime.now())) {
            scheduledAt = DateTime.now().add(const Duration(seconds: 5));
          }

          await NotificationService().scheduleNotification(
            id: name.hashCode, // 🔥 이름 기반 고유 ID (같은 식품 재등록 시 덮어쓰기)
            title: "🧊 유통기한 임박!",
            body: "$name[${expiry.toString().split(' ')[0]}] (1일 전)",
            scheduledDate: scheduledAt,
          );

          debugPrint("✅ 알림 예약: $name → $scheduledAt");
        } catch (e) {
          debugPrint("알림 에러: $e");
        }
      }

      // 3. UI 갱신
      _refreshFoodList();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$name 저장 완료!"), duration: const Duration(seconds: 1)),
        );
      }
    } catch (e) {
      debugPrint("저장 에러: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("날짜 형식을 확인해주세요. (예: 20260518)")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      body: FutureBuilder<List<FoodModel>>(
        future: _foodListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "냉장고가 비어있습니다.",
                style: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
              ),
            );
          }

          final filteredFoods = snapshot.data!.where((food) {
            return food.name.contains(widget.searchQuery);
          }).toList();

          if (filteredFoods.isEmpty) {
            return Center(
              child: Text(
                "검색 결과가 없습니다.",
                style: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: filteredFoods.length,
            itemBuilder: (context, index) {
              final food = filteredFoods[index];

              return Dismissible(
                key: Key("${food.id}_${food.expiryDate.millisecondsSinceEpoch}"),
                direction: DismissDirection.startToEnd,
                confirmDismiss: (direction) => _showDeleteDialog(food.name),
                onDismissed: (direction) async {
                  await _dbService.deleteFood(food.id!);
                  _refreshFoodList();
                },
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 1,
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: food.isAlarmOn
                          ? (isDarkMode ? Colors.orange.withValues(alpha: 0.2) : Colors.orange[50])
                          : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                      child: Icon(
                        food.isAlarmOn ? Icons.notifications_active : Icons.notifications_off,
                        color: food.isAlarmOn ? Colors.orange : Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "기한: ${food.expiryDate.toString().split(' ')[0]}",
                      style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    trailing: _buildDaysLeftText(food.expiryDate),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showManualInputDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDaysLeftText(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final diff = expiry.difference(today).inDays;

    Color color = Colors.green;
    if (diff <= 0) color = Colors.red;
    else if (diff <= 3) color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        diff == 0 ? "D-Day" : (diff < 0 ? "만료" : "D-$diff"),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}