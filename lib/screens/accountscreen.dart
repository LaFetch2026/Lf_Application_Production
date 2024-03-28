// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lafetch/commonwidget/accountwidgets/profilebottom.dart';
import 'package:lafetch/commonwidget/accountwidgets/profilepicwidget.dart';
import 'package:lafetch/commonwidget/accountwidgets/settingwidgit.dart';
import 'package:lafetch/commonwidget/accountwidgets/supportwidgets.dart';
import 'package:lafetch/commonwidget/singlebtn.dart';
import 'package:lafetch/controller/profile_controller.dart';
import 'package:lafetch/screens/cartscreen.dart';
import 'package:lafetch/screens/editprofilescreen.dart';
import 'package:lafetch/screens/orderexchangescreen.dart';
import '../commonwidget/app_text.dart';
import '../utils/constants.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> {
  final controller = Get.put(ProfileController());

  @override
  void initState() {
    controller.getProfileData();
    controller.getAddressData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 40, right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppText(
                  text: "Profile",
                  fontFamily: "Franklin Gothic Regular",
                  fontWeight: FontWeight.w400,
                  color: appbarText,
                  fontSize: 22.sp,
                ),
                const Expanded(
                  child: SizedBox(
                    height: 0,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(const CartScreen());
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: blackColor,
                      child: const ImageIcon(
                        AssetImage(cartImage),
                        color: whiteBorderColor,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.isProfile.value
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*   controller.profileDetails.isBlank
                              ? const ProfilePicWidgets()
                              : */
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: controller
                                                  .profileDetails["name"] ??
                                              "",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: blackColor,
                                          fontSize: 28.sp,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Row(
                                            children: [
                                              const ImageIcon(
                                                AssetImage(phoneImage),
                                                color: greyTextColor,
                                                size: 24,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: AppText(
                                                  text:
                                                      controller.profileDetails[
                                                              "phone"] ??
                                                          "",
                                                  fontFamily:
                                                      "Franklin Gothic Regular",
                                                  fontWeight: FontWeight.w400,
                                                  color: greyTextColor,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        height: 0,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        EditProfileScreen(
                                                          name: controller
                                                                      .profileDetails[
                                                                  "name"] ??
                                                              "",
                                                          email: controller
                                                                      .profileDetails[
                                                                  "email"] ??
                                                              "",
                                                          number: controller
                                                                      .profileDetails[
                                                                  "phone"] ??
                                                              "",
                                                          genderId: controller
                                                                      .profileDetails[
                                                                  "gender"] ??
                                                              "",
                                                        )))
                                            .then((value) => setState(
                                                  () {
                                                    controller.getProfileData();
                                                  },
                                                ));
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: AppText(
                                          text: "Edit",
                                          fontFamily: "Franklin Gothic",
                                          fontWeight: FontWeight.w500,
                                          color: colorPrimary,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                color: backWhite,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 16, bottom: 16),
                                  child: Row(
                                    children: [
                                      const ImageIcon(
                                        AssetImage(pointImage),
                                        color: btnTextColor,
                                        size: 24,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: AppText(
                                          text: "100 Lafetch points",
                                          fontFamily: "Franklin Gothic Regular",
                                          fontWeight: FontWeight.w400,
                                          color: btnTextColor,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 20, bottom: 20),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: whiteBack,
                                          border: Border.all(
                                              color: profileBorder, width: 1)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 10,
                                            bottom: 10),
                                        child: Row(
                                          children: [
                                            Image.asset(rewardsImage,
                                                height: 40,
                                                width: 40,
                                                fit: BoxFit.cover),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: AppText(
                                                text: "Rewards",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: btnTextColor,
                                                fontSize: 14.sp,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        width: 0,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: whiteBack,
                                          border: Border.all(
                                              color: profileBorder, width: 1)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 10,
                                            bottom: 10),
                                        child: Row(
                                          children: [
                                            Image.asset(mysteryBoxImage,
                                                height: 40,
                                                width: 40,
                                                fit: BoxFit.cover),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: AppText(
                                                text: "Mystery Box",
                                                fontFamily:
                                                    "Franklin Gothic Regular",
                                                fontWeight: FontWeight.w400,
                                                color: btnTextColor,
                                                fontSize: 14.sp,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 16, right: 16),
                            child: AppText(
                              text: "My Account",
                              fontFamily: "Franklin Gothic Bold",
                              fontWeight: FontWeight.w700,
                              color: nameText,
                              fontSize: 18.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(const OrderExchangeScreen());
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, left: 16, right: 16),
                              child: AppText(
                                text: "Orders & Exchanges",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: nameText,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, left: 16, right: 16),
                              child: AppText(
                                text: "My Wishlist",
                                fontFamily: "Franklin Gothic Regular",
                                fontWeight: FontWeight.w400,
                                color: nameText,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          /*  controller.profileDetails.isEmpty
                              ? const SizedBox(
                                  height: 0,
                                )
                              : */
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 16, right: 16),
                                  child: AppText(
                                    text: "Customer Care",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: nameText,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 16, right: 16),
                                  child: AppText(
                                    text: "Saved Addresses",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: nameText,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 16, right: 16),
                                  child: AppText(
                                    text: "Payments & Currencies",
                                    fontFamily: "Franklin Gothic Regular",
                                    fontWeight: FontWeight.w400,
                                    color: nameText,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              const SettingWidgets(),
                            ],
                          ),
                          const SupportWidgets(visibilty: false),
                          /*   controller.profileDetails.isEmpty
                              ? const SizedBox(
                                  height: 0,
                                )
                              : */
                          Padding(
                            padding: const EdgeInsets.only(top: 60, bottom: 20),
                            child: SingleButton(
                                label: "Logout",
                                textColor: redColor,
                                onPressed: () {},
                                backgroundColor: whiteTextColor,
                                borderColor: redColor),
                          ),
                          const ProfileBottom(
                            version: " 1.2.1",
                          )
                        ],
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
