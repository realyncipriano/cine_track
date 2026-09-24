import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cine_track/widgets/like_button.dart';

void main() {
  testWidgets('LikeButton displays count and reacts to tap', (tester) async {
    int toggleCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LikeButton(
            reviewId: 1,
            likesCount: 5,
            isLiked: false,
            onToggle: () => toggleCount++,
          ),
        ),
      ),
    );

    // Verify the count is displayed
    expect(find.text('5'), findsOneWidget);

    // Verify the outline heart icon is shown (not liked)
    expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    // Tap the button
    await tester.tap(find.byType(LikeButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify callback was called
    expect(toggleCount, 1);
  });

  testWidgets('LikeButton shows filled heart when liked', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LikeButton(
            reviewId: 1,
            likesCount: 3,
            isLiked: true,
            onToggle: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_outline), findsNothing);
  });
}
