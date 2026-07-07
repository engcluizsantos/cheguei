import 'package:cheguei/core/widgets/cheguei_button.dart';
import 'package:cheguei/core/widgets/cheguei_textfield.dart';
import 'package:flutter/material.dart';
import 'package:cheguei/models/user_model.dart';
import 'package:cheguei/services/storage/storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:cheguei/app/app_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();

  bool isElderly = false;
  bool isPregnant = false;
  bool hasDisability = false;
  bool reducedMobility = false;

  bool preferShortestTime = false;
  bool preferLowestCost = false;
  bool avoidTransfers = false;
  bool needAccessibility = false;

  UserModel? user;

  void loadUser() {
    user = StorageService.getUser();

    if (user == null) return;

    nameController.text = user!.name;
    ageController.text = user!.age.toString();

    isElderly = user!.isElderly;
    isPregnant = user!.isPregnant;
    hasDisability = user!.hasDisability;
    reducedMobility = user!.reducedMobility;

    preferShortestTime = user!.preferShortestTime;
    preferLowestCost = user!.preferLowestCost;
    avoidTransfers = user!.avoidTransfers;
    needAccessibility = user!.needAccessibility;
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChegueiTextField(controller: nameController, label: 'Nome'),

                const SizedBox(height: 16),

                ChegueiTextField(
                  controller: ageController,
                  label: 'Idade',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Necessidades de mobilidade',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                CheckboxListTile(
                  value: isElderly,
                  title: const Text('Idoso'),
                  onChanged: (value) {
                    setState(() {
                      isElderly = value!;
                    });
                  },
                ),

                CheckboxListTile(
                  value: isPregnant,
                  title: const Text('Gestante'),
                  onChanged: (value) {
                    setState(() {
                      isPregnant = value!;
                    });
                  },
                ),

                CheckboxListTile(
                  value: hasDisability,
                  title: const Text('Pessoa com deficiência'),
                  onChanged: (value) {
                    setState(() {
                      hasDisability = value!;
                    });
                  },
                ),

                CheckboxListTile(
                  value: reducedMobility,
                  title: const Text('Mobilidade reduzida'),
                  onChanged: (value) {
                    setState(() {
                      reducedMobility = value!;
                    });
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  'Preferências',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                CheckboxListTile(
                  value: preferShortestTime,
                  title: const Text('Menor tempo'),
                  onChanged: (value) {
                    setState(() {
                      preferShortestTime = value!;
                    });
                  },
                ),

                CheckboxListTile(
                  value: preferLowestCost,
                  title: const Text('Menor custo'),
                  onChanged: (value) {
                    setState(() {
                      preferLowestCost = value!;
                    });
                  },
                ),

                CheckboxListTile(
                  value: avoidTransfers,
                  title: const Text('Evitar baldeações'),
                  onChanged: (value) {
                    setState(() {
                      avoidTransfers = value!;
                    });
                  },
                ),

                CheckboxListTile(
                  value: needAccessibility,
                  title: const Text('Acessibilidade'),
                  onChanged: (value) {
                    setState(() {
                      needAccessibility = value!;
                    });
                  },
                ),

                const SizedBox(height: 32),

                ChegueiButton(
                  text: 'Salvar Perfil',
                  onPressed: () {
                    context.go(AppRoutes.home);
                  },
                ),

                //ChegueiButton(text: 'Salvar Perfil', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
