import "package:flutter/material.dart";
import "package:store_responsive_dashboard/components/constants.dart";

class CardWidget extends StatelessWidget {
  const CardWidget(
      {Key? key,
      required this.title,
      required this.metric,
      required this.subtitle,
      this.press})
      : super(key: key);

  final String subtitle;
  final Widget metric;
  final String title;
  final Function? press;

  @override
  Widget build(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return InkWell(
      onTap: press as void Function()?,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 100,
          width: 300,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            // surfaceTintColor: Colors.green,
            // shadowColor: Color.fromARGB(255, 244, 204, 252),
            elevation: 15,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textAlign: TextAlign.left,
                        title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(subtitle)
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [metric],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
