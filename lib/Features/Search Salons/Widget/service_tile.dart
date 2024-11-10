import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTapButton;
  final VoidCallback onTapTile;

  const CustomListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTapButton,
    required this.onTapTile,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 5),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            // Using ListTile to structure the services section
            ListTile(
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
              ),
              subtitle: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                      fontSize: 14,
                    ),
              ),
              trailing: TextButton(
                onPressed: onTapButton,
                child: Text(
                  buttonText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
              ),
              onTap: onTapTile,
            ),
          ],
        ),
      ),
    );
  }
}
