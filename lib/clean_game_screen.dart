import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/clean_game.dart';

class CleanGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: CleanGame(),
        overlayBuilderMap: {
          'Controls': (context, game) {
            return Positioned(
              bottom: 40,
              right: 40,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () => (game as CleanGame).tryClean(),
                    child: Text("치우기"),
                  ),
                ],
              ),
            );
          },
        },
        initialActiveOverlays: const ['Controls'],
      )

    );
  }
}
