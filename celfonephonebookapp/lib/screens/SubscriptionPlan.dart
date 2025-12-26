import 'package:flutter/material.dart';

class SubscriptionPlan extends StatefulWidget {
  const SubscriptionPlan({super.key});

  @override
  State<SubscriptionPlan> createState() => _SubscriptionPlanState();
}

class _SubscriptionPlanState extends State<SubscriptionPlan> {
  bool isYearly = true;

  final Map<String, Map<String, String>> plans = {
    "FREE LISTING": {"monthly": "FREE", "yearly": "FREE"},
    "NORMAL LISTING": {"monthly": "₹200", "yearly": "₹2,000"},
    "PRIORITY LISTING": {"monthly": "₹500", "yearly": "₹5,000"},
    "PREMIUM LISTING": {"monthly": "₹750", "yearly": "₹7,500"},
  };

  String getMonthlyPrice(String plan) => plans[plan]!["monthly"]!;
  String getYearlyPrice(String plan) => plans[plan]!["yearly"]!;

  String getSavings(String plan) {
    if (plan == "FREE LISTING") return "";
    final monthly = double.parse(
      plans[plan]!["monthly"]!.replaceAll("₹", "").trim(),
    );
    final yearly = double.parse(
      plans[plan]!["yearly"]!.replaceAll("₹", "").replaceAll(",", "").trim(),
    );
    final saved = (monthly * 12) - yearly;
    return saved > 0 ? "Save ₹${saved.toInt()}" : "";
  }

  Color getBorderColor(String title) {
    switch (title) {
      case "FREE LISTING":
        return Colors.grey.shade600;
      case "NORMAL LISTING":
        return const Color.fromARGB(255, 255, 0, 251);
      case "PRIORITY LISTING":
        return const Color.fromARGB(255, 255, 221, 0);
      case "PREMIUM LISTING":
        return const Color.fromARGB(255, 255, 208, 0);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Branding Ads Subscription",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tariff & Facilities",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _toggleButton("Monthly", !isYearly),
                    const SizedBox(width: 8),
                    _toggleButton("Yearly", isYearly),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            buildPlanCard(
              title: "FREE LISTING",
              color: Colors.grey.shade800,
              features: List.filled(12, false)..setAll(0, [true, true, true]),
            ),
            buildPlanCard(
              title: "NORMAL LISTING",
              color: const Color.fromARGB(255, 255, 0, 251),
              features: List.filled(12, false)
                ..setAll(0, [true, true, true, true, true, true, true]),
            ),
            buildPlanCard(
              title: "PRIORITY LISTING",
              color: const Color.fromARGB(255, 255, 221, 0),
              features: List.filled(12, false)
                ..setAll(0, [true, true, true, true, true, true, true, true]),
            ),
            buildPlanCard(
              title: "PREMIUM LISTING",
              color: const Color.fromARGB(255, 255, 221, 0),
              features: List.filled(12, true),
              isPopular: true,
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                ),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment gateway in progress!")),
                ),
                child: Text(
                  isYearly
                      ? "Subscribe Yearly & Save Big!"
                      : "Subscribe Monthly",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String text, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => isYearly = text == "Yearly"),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.deepOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget buildPlanCard({
    required String title,
    required Color color,
    required List<bool> features,
    bool isPopular = false,
  }) {
    final monthlyPrice = getMonthlyPrice(title);
    final yearlyPrice = getYearlyPrice(title);
    final savings = getSavings(title);
    final borderColor = getBorderColor(title);

    const featureNames = [
      "Address",
      "Communication",
      "Enquiry",
      "Highlight",
      "Description",
      "Location Map",
      "Website Link",
      "Leads",
      "Product Photos",
      "Products Description",
      "Product Pricing",
      "Product Enquiry",
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isPopular ? 3.5 : 2.8),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "MOST POPULAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isYearly && title != "FREE LISTING") ...[
                Text(
                  "₹${(double.parse(monthlyPrice.replaceAll("₹", "").trim()) * 12).toInt()}",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 2.8,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                isYearly ? yearlyPrice : monthlyPrice,
                style: TextStyle(
                  fontSize: isYearly ? 34 : 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  isYearly ? "/year" : "/month",
                  style: TextStyle(color: Colors.grey[600], fontSize: 17),
                ),
              ),
            ],
          ),
          if (isYearly && savings.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade500, width: 1.5),
                ),
                child: Text(
                  savings,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Divider(color: Colors.grey, height: 30),
          const SizedBox(height: 10),
          ...List.generate(featureNames.length, (i) {
            final hasFeature = i < features.length ? features[i] : false;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    hasFeature ? Icons.check_circle : Icons.cancel,
                    size: 26,
                    color: hasFeature ? color : Colors.grey[400],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      featureNames[i],
                      style: TextStyle(
                        fontSize: 16.5,
                        color: hasFeature ? Colors.black87 : Colors.grey[500],
                        fontWeight: hasFeature
                            ? FontWeight.w500
                            : FontWeight.normal,
                        decoration: hasFeature
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
