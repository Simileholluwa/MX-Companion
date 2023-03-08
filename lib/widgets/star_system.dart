import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StarPage extends StatefulWidget {
  final int? value;
  final bool? canChange;
  const StarPage({super.key, this.value, this.canChange = true});

  static final RxInt starValue = 3.obs;

  @override
  State<StarPage> createState() => _StarPageState();
}

class _StarPageState extends State<StarPage> {

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return StarRating(
          onChanged: (index) {
            setState(() {
              StarPage.starValue.value = index;
            });
          },
          value: widget.value ?? StarPage.starValue.value,
          changeAble: widget.canChange,
        );
      },
    );
  }
}

class StarRating extends StatelessWidget {
  final void Function(int index)? onChanged;
  final int value;
  final IconData? filledStar;
  final IconData? unfilledStar;
  final bool? changeAble;

  const StarRating({
    Key? key,
    this.onChanged,
    this.value = 0,
    this.filledStar,
    this.unfilledStar,
    this.changeAble = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const size = 36.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: changeAble == false ? () {}: onChanged != null
              ? () {
                  onChanged!(value == index + 1 ? index : index + 1);
                }
              : null,
          color: index < value ? Theme.of(context).primaryColor : null,
          iconSize: size,
          icon: Icon(
            index < value
                ? filledStar ?? Icons.star
                : unfilledStar ?? Icons.star_border,
          ),
          padding: EdgeInsets.zero,
          tooltip: '${index + 1} of 5',
          splashRadius: changeAble == false ? 1 : 30,
        );
      }),
    );
  }
}
