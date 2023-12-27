import 'package:flutter/material.dart';

class ListColor extends StatefulWidget {
  const ListColor({
    super.key,
    required this.colors,
    this.onSelected,
    this.indexSelected,
  });

  final List<String> colors;
  final void Function(String selected)? onSelected;
  final int? indexSelected;

  @override
  State<ListColor> createState() => _ListColorState();
}

class _ListColorState extends State<ListColor> {
  late int? _indexSelected;

  @override
  void initState() {
    super.initState();
    _indexSelected = widget.indexSelected ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.colors.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              _indexSelected = index;
              if (widget.onSelected != null) {
                widget.onSelected!(widget.colors[index]);
              }
            },
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                color: Color(
                  int.parse(
                    widget.colors[index].replaceAll("#", "0xFF"),
                  ),
                ),
                shape: BoxShape.circle,
              ),
              child: _indexSelected == null
                  ? const SizedBox()
                  : _indexSelected == index
                      ? Icon(
                          Icons.check,
                          color: _indexSelected == widget.colors.length - 1
                              ? Colors.black
                              : Colors.white,
                        )
                      : const SizedBox(),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 16,
          );
        },
      ),
    );
  }
}
