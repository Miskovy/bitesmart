import 'package:bite_smart/features/profile/screens/personalData.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_event.dart';
import 'package:bite_smart/features/profile/data/models/profile_setup_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class MedicalConditionsScreen extends StatefulWidget {
  const MedicalConditionsScreen({super.key});

  @override
  State<MedicalConditionsScreen> createState() => _MedicalConditionsScreenState();
}

class _MedicalConditionsScreenState extends State<MedicalConditionsScreen> {
  final Map<String, bool> _conditionsState = {
    'diabetes': false,
    'hypertension': false,
    'pcos': false,
    'celiac': false,
    'ibs': false,
    'anemia': false,
  };
  String _diabetesType = 'type2';

  @override
  void initState() {
    super.initState();
    final currentConditions = context.read<ProfileSetupBloc>().state.data.medicalConditions;
    _conditionsState['diabetes'] = currentConditions.isDiabetesType1 || currentConditions.isDiabetesType2;
    if (currentConditions.isDiabetesType1) {
      _diabetesType = 'type1';
    } else if (currentConditions.isDiabetesType2) {
      _diabetesType = 'type2';
    } else {
      _diabetesType = 'type2';
    }
    _conditionsState['hypertension'] = currentConditions.isHypertension;
    _conditionsState['pcos'] = currentConditions.isPCOS;
    _conditionsState['celiac'] = currentConditions.isCeliacDisease;
    _conditionsState['ibs'] = currentConditions.isIBS;
    _conditionsState['anemia'] = currentConditions.isAnemia;
  }

  Widget _buildDiabetesTypePill(String type, String label) {
    bool isSelected = _diabetesType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _diabetesType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF388E3C) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF1B5E20) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'medical.title'.tr(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                Text(
                  'medical.subtitle'.tr(),
                  style: const TextStyle(fontSize: 15, color: Colors.blueGrey, height: 1.4),
                ),
                const SizedBox(height: 12),

                _buildSectionTitle('medical.common'.tr()),
                _buildCategoryCard([
                  _buildConditionRow(
                    key: 'diabetes',
                    title: 'medical.diabetes_title'.tr(),
                    desc: 'medical.diabetes_desc'.tr(),
                    icon: Icons.opacity,
                    iconColor: Colors.blue,
                    iconBg: const Color(0xFFE3F2FD),
                  ),
                  const Divider(height: 1, indent: 55),
                  if (_conditionsState['diabetes'] == true) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 55, right: 16, top: 8, bottom: 8),
                      child: Row(
                        children: [
                          _buildDiabetesTypePill('type1', 'medical.diabetes_type1'.tr()),
                          const SizedBox(width: 10),
                          _buildDiabetesTypePill('type2', 'medical.diabetes_type2'.tr()),
                        ],
                      ),
                    ),
                    const Divider(height: 1, indent: 55),
                  ],
                  _buildConditionRow(
                    key: 'hypertension',
                    title: 'medical.hypertension_title'.tr(),
                    desc: 'medical.hypertension_desc'.tr(),
                    icon: Icons.favorite,
                    iconColor: Colors.red,
                    iconBg: const Color(0xFFFFEBEE),
                  ),
                  const Divider(height: 1, indent: 55),
                  _buildConditionRow(
                    key: 'pcos',
                    title: 'medical.pcos_title'.tr(),
                    desc: 'medical.pcos_desc'.tr(),
                    icon: Icons.spa,
                    iconColor: Colors.purple,
                    iconBg: const Color(0xFFF3E5F5),
                  ),
                ]),

                const SizedBox(height: 14),

                _buildSectionTitle('medical.digestive'.tr()),
                _buildCategoryCard([
                  _buildConditionRow(
                    key: 'celiac',
                    title: 'medical.celiac_title'.tr(),
                    desc: 'medical.celiac_desc'.tr(),
                    icon: Icons.grain,
                    iconColor: Colors.orange,
                    iconBg: const Color(0xFFFFF3E0),
                  ),
                  const Divider(height: 1, indent: 55),
                  _buildConditionRow(
                    key: 'ibs',
                    title: 'medical.ibs_title'.tr(),
                    desc: 'medical.ibs_desc'.tr(),
                    icon: Icons.sentiment_neutral,
                    iconColor: Colors.amber,
                    iconBg: const Color(0xFFFFFDE7),
                  ),
                ]),

                const SizedBox(height: 14),

                _buildSectionTitle('medical.metabolic'.tr()),
                _buildCategoryCard([
                  _buildConditionRow(
                    key: 'anemia',
                    title: 'medical.anemia_title'.tr(),
                    desc: 'medical.anemia_desc'.tr(),
                    icon: Icons.water_drop,
                    iconColor: Colors.redAccent,
                    iconBg: const Color(0xFFFFEBEE),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
      
      bottomNavigationBar: 
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
          child: FractionallySizedBox(
            widthFactor: .6,
            child: SizedBox(
              width: .6* MediaQuery.of(context).size.width,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  final isDiabetesSelected = _conditionsState['diabetes'] == true;
                  final medicalConditions = MedicalConditionsData(
                    isDiabetesType1: isDiabetesSelected && _diabetesType == 'type1',
                    isDiabetesType2: isDiabetesSelected && _diabetesType == 'type2',
                    isHypertension: _conditionsState['hypertension'] == true,
                    isPCOS: _conditionsState['pcos'] == true,
                    isAnemia: _conditionsState['anemia'] == true,
                    isCeliacDisease: _conditionsState['celiac'] == true,
                    isIBS: _conditionsState['ibs'] == true,
                  );

                  context.read<ProfileSetupBloc>().add(SetMedicalConditionsEvent(medicalConditions));

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PersonalDataScreen())
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'medical.continue'.tr(),
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildCategoryCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildConditionRow({
    required String key,
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          Switch.adaptive(
            value: _conditionsState[key]!,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF00C853),
            onChanged: (bool value) {
              setState(() {
                _conditionsState[key] = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
