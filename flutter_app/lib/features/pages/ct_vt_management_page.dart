import 'package:flutter/material.dart';
import 'package:flutter_python_grpc/core/widget_keys.dart';
import 'package:flutter_python_grpc/core/widgets/refresh_action_button.dart';
import 'package:flutter_python_grpc/grpc/meter_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ConsumerStatefulWidget, ConsumerState;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/widgets/number_input_field.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/breadcrumb.dart';

class CtVtManagementPage extends ConsumerStatefulWidget {
  const CtVtManagementPage({super.key});

  @override
  ConsumerState<CtVtManagementPage> createState() => _CtVtManagementPageState();
}


class _CtVtManagementPageState extends ConsumerState<CtVtManagementPage> {
  late IMeterClient _client;
  bool _loading = false;

  
  late Map<String, Future<void> Function()> getMethods;

  late Map<String, Future<void> Function(int)> setMethods;
  
  final TextEditingController primaryCtController = TextEditingController();
  final TextEditingController secondaryCtController = TextEditingController();
  final TextEditingController ratioCtController = TextEditingController();

  final TextEditingController primaryVtController = TextEditingController();
  final TextEditingController ratioValueVtController = TextEditingController();
  final TextEditingController ratioVtController = TextEditingController();
  
  
  @override
  void initState() {
    super.initState();
    
   getMethods = {
      'PrimaryCT': _readPrimaryValueCT,
      'SecondaryCT': _readSecondaryValueCT,
      'PrimaryVT': _readPrimaryValueVT,
      'RatioValueVT': _readRatioValueVT
    };

    

    _client = meterClientFactory();

    setMethods = {
      'PrimaryCT': _client.setPrimaryCt,
      'SecondaryCT': _client.setSecondaryCt,
      'PrimaryVT': _client.setPrimaryVt,
      'RatioValueVT': _client.setRatioValueVt
    };
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       await _getAll();
    });

  }
  void updateRatioCt() {
    final primaryCt = int.tryParse(primaryCtController.text.trim()) ?? 0;
    final secondaryCt = int.tryParse(secondaryCtController.text.trim()) ?? 0;

    if (primaryCt > 0 && secondaryCt > 0) {
      final ratio = primaryCt / secondaryCt;
      ratioCtController.text = ratio.toStringAsFixed(2);
    } else {
      ratioCtController.text = "";
    }
  }
  void updateRatioVt(){
    final primaryVt = int.tryParse(primaryVtController.text.trim()) ?? 0;
    final ratioValueVt = int.tryParse(ratioValueVtController.text.trim()) ?? 0;

    if (primaryVt > 0 && ratioValueVt > 0) {
      final ratio = primaryVt / ratioValueVt;
      ratioVtController.text = ratio.toStringAsFixed(2);
    } else {
      ratioVtController.text = "";
    }
  }
  Future<void> _getAll ()async {
     setState(() {
        _loading = true;
      });
      await _readPrimaryValueCT();
      await _readSecondaryValueCT();
      updateRatioCt();
      await _readPrimaryValueVT();
      await _readRatioValueVT();
      updateRatioVt();
      setState(() {
        _loading = false;
      });
  }
  Future<void> _readPrimaryValueCT() async {
    
    try {
      final response = await _client.getPrimaryCt();
      primaryCtController.text = response.toString();
      updateRatioCt();
    } catch (e) {
      debugPrint("Error reading Primary Value CT: $e");
    } 
  }

  Future<void> _readSecondaryValueCT() async {
    try {
      final response = await _client.getSecondaryCt();
      secondaryCtController.text = response.toString();
      updateRatioCt();
    } catch (e) {
      debugPrint("Error reading Secondary Value CT: $e");
    } 
  }


 
  Future<void> _readPrimaryValueVT() async {
    
    try {
      final response = await _client.getPrimaryVt();
      primaryVtController.text = response.toString();
      updateRatioVt();
    } catch (e) {
      debugPrint("Error reading Primary Value VT: $e");
    } 
  }

  Future<void> _readRatioValueVT() async {
    
    try {
      final response = await _client.getRatioValueVt();
      ratioValueVtController.text = response.toString();
      updateRatioVt();
    } catch (e) {
      debugPrint("Error reading Ratio Value VT: $e");
    } 
  }

  
  
  void onRead(String field) {
  final getMethod = getMethods[field];
  if (getMethod == null) {
    return;
  }

  setState(() {
    _loading = true;
  });

  getMethod().then((_) {
    setState(() {
      _loading = false;
    });
  }).catchError((error) {
    setState(() {
      _loading = false;
    });
    print("Error: $error");
  });
}


  void onWrite(String field, String value) {
  final setMethod = setMethods[field];
  if (setMethod == null) return;

  setState(() => _loading = true);

  setMethod(int.parse(value)).then((_) {
    if (!mounted) return;

    setState(() => _loading = false);

    _showSuccessDialog("Value written successfully ✅");
  }).catchError((error) {
    if (!mounted) return;

    setState(() => _loading = false);

    _showErrorDialog("Failed to write value ❌\n$error");

    print("Error: $error");
  });
}

void _showSuccessDialog(String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Success"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Error"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}


/// ---------------- RESPONSIVE SECTION ----------------
  Widget buildSection(List<Widget> fields) {
    
return Align(
    alignment: Alignment.topLeft,
 child: Wrap(
      runAlignment: WrapAlignment.start,
      alignment: WrapAlignment.start,
      spacing: 16,
      runSpacing: 16,
      children: fields.map((field) {
        return SizedBox(
          width: 300,
          child: field,
        );
      }).toList(),
    ));
  }

  @override
Widget build(BuildContext context) {
  final sc = SemanticColors.of(context);
  return Scaffold(
    key: const Key('ct_vt_screen'),

    appBar: AppBar(
      key: const Key('app_bar'),
      title: const Text('CT VT Management'),
      backgroundColor: sc.primary,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      actions: [
        RefreshAppBarButton(
          key: const Key('refresh_button'),
          onPressed: _getAll,
        ),
      ],
    ),

    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: const Breadcrumb(
              segments: ['Menu', 'Electricity Objects', 'CT VT Management']),
        ),
        Expanded(
          child: Stack(
      key: const Key(CTVTKeys.mainStack),
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          key: const Key(CTVTKeys.scrollView),
          padding: const EdgeInsets.all(16),
          child: Column(
            key: const Key(CTVTKeys.mainColumn),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// -------- CT SECTION --------
              const SectionTitle(
                key: Key(CTVTKeys.ctSectionTitle),
                title: "CT Configuration",
              ),

              buildSection([
                NumberInputField(
                  key: const Key(CTVTKeys.ctPrimaryField),
                  label: "Primary Value CT",
                  controller: primaryCtController,
                  hasButtons: true,
                  onRead: () => onRead("PrimaryCT"),
                  onWrite: () =>
                      onWrite("PrimaryCT", primaryCtController.text),
                ),

                NumberInputField(
                  key: const Key(CTVTKeys.ctSecondaryField),
                  label: "Secondary Value CT",
                  controller: secondaryCtController,
                  hasButtons: true,
                  onRead: () => onRead("SecondaryCT"),
                  onWrite: () =>
                      onWrite("SecondaryCT", secondaryCtController.text),
                ),

                NumberInputField(
                  key: const Key(CTVTKeys.ctRatioField),
                  label: "Ratio CT",
                  controller: ratioCtController,
                  hasButtons: false,
                ),
              ]),

              const SizedBox(height: 20),

              /// -------- VT SECTION --------
              const SectionTitle(
                key: Key(CTVTKeys.vtSectionTitle),
                title: "VT Configuration",
              ),

              buildSection([
                NumberInputField(
                  key: const Key(CTVTKeys.vtPrimaryField),
                  label: "Primary Value VT",
                  controller: primaryVtController,
                  hasButtons: true,
                  onRead: () => onRead("PrimaryVT"),
                  onWrite: () =>
                      onWrite("PrimaryVT", primaryVtController.text),
                ),

                NumberInputField(
                  key: const Key(CTVTKeys.vtRatioValueField),
                  label: "Ratio Value VT",
                  controller: ratioValueVtController,
                  hasButtons: true,
                  onRead: () => onRead("RatioValueVT"),
                  onWrite: () => onWrite(
                      "RatioValueVT", ratioValueVtController.text),
                ),

                NumberInputField(
                  key: const Key(CTVTKeys.vtRatioField),
                  label: "Ratio VT",
                  controller: ratioVtController,
                  hasButtons: false,
                ),
              ]),
            ],
          ),
        ),

        /// -------- LOADING --------
        if (_loading)
          Positioned.fill(
            child: Container(
              key: const Key('loading_overlay'),
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Lottie.asset(
                  'assets/animations/data.json',
                  key: const Key('loading_animation'),
                  width: 200,
                  height: 200,
                ),
              ),
            ),
          ),
      ],
    ),
        ),
      ],
    ),
  );
}
}