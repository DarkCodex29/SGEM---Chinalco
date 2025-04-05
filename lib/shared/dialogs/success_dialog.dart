import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sgem/shared/widgets/app_button.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    this.title = 'Los datos se guardaron \nsatisfactoriamente',
    super.key,
  });

  final String title;

  Future<void> show(BuildContext context) async => showDialog<void>(
        context: context,
        builder: build,
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: SizedBox(
        width: 350,
        height: 250,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 120),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/check.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: context.pop,
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Calibri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButton.green(
                      text: 'Aceptar',
                      onPressed: context.pop,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
