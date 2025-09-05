import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auction_controller.dart';

void ChooseSeconds(BuildContext context) {
  var theme = Theme.of(context);
  AuctionController auctionController = Get.find<AuctionController>();
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: auctionController.auctionseconds.length,
                  itemBuilder: (c, i) {
                    String seconds = auctionController.auctionseconds[i];
                    return RadioListTile<String>(
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      title: Text(
                        "$seconds s",
                        style: theme.textTheme.headlineSmall,
                      ),
                      value: seconds,
                      groupValue:
                          auctionController.selectedSeconds.value.toString(),
                      onChanged: (val) {
                        Get.back();
                        auctionController.selectedSeconds.value =
                            int.parse(val!);
                        auctionController.selectedSecondsController.text =
                            "$val s";
                      },
                      controlAffinity:
                          ListTileControlAffinity.trailing, // 👈 radio on right
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
