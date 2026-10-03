import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/locale_provider.dart';

class DateTimeSelectionWidget extends StatelessWidget {
  const DateTimeSelectionWidget({
    super.key,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.onCameraCountSelected,
    required this.onFpsSelected,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedCameraCount,
    required this.selectedFps,
    required this.note,
    required this.onNoteSelected,
    required this.isLongJump,
    required this.onLongJumpChanged,
  });

  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;
  final Function(int) onCameraCountSelected;
  final Function(int) onFpsSelected;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int selectedCameraCount;
  final int selectedFps;
  final String note;
  final Function(String) onNoteSelected;
  final bool isLongJump;
  final ValueChanged<bool> onLongJumpChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Wrap(
          spacing: 32,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            Row(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    l10n.date,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        onDateSelected(picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        hintText: l10n.selectDate,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    l10n.time,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: InkWell(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );

                      if (picked != null) {
                        onTimeSelected(picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        hintText: l10n.time,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        selectedTime.format(context),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Row(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    l10n.cameraCount,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<int>(
                    hint: Row(
                      children: [
                        Text(
                          l10n.cameraCount,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    items: [1, 2, 3, 4, 5]
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item,
                            child: Text(
                              item.toString(),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    value: selectedCameraCount,
                    onChanged: (value) {
                      if (value != null) {
                        onCameraCountSelected(value);
                      }
                    },
                    buttonStyleData: ButtonStyleData(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor)),
                      ),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_forward_ios_outlined),
                      iconSize: 12,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                      scrollbarTheme: const ScrollbarThemeData(radius: Radius.circular(40)),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 12, right: 12),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    l10n.fps,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<int>(
                    hint: Row(
                      children: [
                        Text(
                          l10n.fps,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    items: [30, 60]
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item,
                            child: Text(
                              item.toString(),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    value: selectedFps,
                    onChanged: (value) {
                      if (value != null) {
                        onFpsSelected(value);
                      }
                    },
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      width: 100,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor)),
                      ),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_forward_ios_outlined),
                      iconSize: 12,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                      scrollbarTheme: const ScrollbarThemeData(radius: Radius.circular(40)),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 12, right: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              l10n.longJumpMode,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(l10n.longJumpModeDescription),
            value: isLongJump,
            onChanged: onLongJumpChanged,
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    l10n.notes,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (constraints.maxWidth < 800)
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          onNoteSelected(value);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: l10n.notes,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: constraints.maxWidth * 0.6,
                    child: TextField(
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          onNoteSelected(value);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: l10n.notes,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
