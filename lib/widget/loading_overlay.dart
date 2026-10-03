import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.loadingText});
  final String? loadingText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Opacity(opacity: 0.5, child: ModalBarrier(dismissible: false, color: Colors.black)),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitCircle(
              size: 80,
              itemBuilder: (context, index) {
                final colors = [Colors.white, Theme.of(context).primaryColorDark];
                final color = colors[index % colors.length];
                return DecoratedBox(decoration: BoxDecoration(color: color));
              },
            ),
            SizedBox(height: 16),
            Text(
              loadingText ?? "Loading...",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
