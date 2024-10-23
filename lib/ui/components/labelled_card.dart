import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LabelledCard extends StatefulWidget {
  LabelledCard(
      {super.key,
      required this.label,
      required this.heading,
      this.subLabel,
      this.style = "secondary"});
  String label, heading, style;
  String? subLabel;
  @override
  State<LabelledCard> createState() => _LabelledCardState();
}

class _LabelledCardState extends State<LabelledCard> {
  @override
  Widget build(BuildContext context) {
    Color container = widget.style == 'secondary'
        ? Theme.of(context).colorScheme.secondaryContainer
        : widget.style == 'tertiary'
            ? Theme.of(context).colorScheme.tertiaryContainer
            : widget.style == 'error'
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.surfaceContainer;
    Color onContainer = widget.style == 'secondary'
        ? Theme.of(context).colorScheme.onSecondaryContainer
        : widget.style == 'tertiary'
            ? Theme.of(context).colorScheme.onTertiaryContainer
            : widget.style == 'error'
                ? Theme.of(context).colorScheme.onErrorContainer
                : Theme.of(context).colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        radius: 100,
        onTap: () {},
        splashColor: container,
        focusColor: container,
        highlightColor: container,
        hoverColor: container,
        splashFactory: InkRipple.splashFactory,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: container,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.heading,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: onContainer,
                      ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: onContainer,
                        ),
                  ),
                  Text(
                    widget.subLabel ?? "",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onContainer,
                        ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
