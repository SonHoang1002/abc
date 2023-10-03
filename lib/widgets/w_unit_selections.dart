import 'package:flutter/material.dart';
import 'package:photo_to_pdf/commons/colors.dart';
import 'package:photo_to_pdf/commons/constants.dart';
import 'package:photo_to_pdf/helpers/navigator_route.dart';
import 'package:photo_to_pdf/models/project.dart';
import 'package:photo_to_pdf/widgets/w_text_content.dart';

class WUnitSelections extends StatelessWidget {
  final Unit unitValue;
  final void Function(Unit value) onSelected;
  final void Function(Unit value) onDone;
  const WUnitSelections(
      {super.key, required this.unitValue, required this.onSelected,required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).canvasColor,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: LIST_UNIT
                .map<Widget>((e) => _buildUnitItem(
                    context: context,
                    unit: e.title,
                    isFocus: unitValue.value == e.value,
                    onTap: () {
                      onSelected(e);
                    }))
                .toList(),
          ),
          _buildUnitItem(
            context: context,
            unit: "Done",
            isFocus: true,
            onTap: () {
             onDone(unitValue);
              FocusManager.instance.primaryFocus!.unfocus();
              popNavigator(context);
            },
          )
        ],
      ),
    );
  }

  Widget _buildUnitItem(
      {required BuildContext context,
      required String unit,
      required bool isFocus,
      void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isFocus
                ? const Color.fromRGBO(10, 132, 255, 1)
                : Theme.of(context).cardColor),
        child: WTextContent(
            value: unit,
            textSize: 14,
            textLineHeight: 16.71,
            textColor:
                isFocus ? colorWhite : const Color.fromRGBO(10, 132, 255, 1)),
      ),
    );
  }
}
