import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String dateTime;
  final double balance;

  final double cramount;
  final double dramount;

  const TransactionCard({
    Key? key,
    required this.dateTime,
    required this.balance,
    required this.cramount,
    required this.dramount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // First Column (Date and Balance)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateTime,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                /* Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50], // Light pink background
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Bal. $balance',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54, // Grey text color
                    ),
                  ),
                ),*/
              ],
            ),

            // Vertical Divider
            Container(
              height: 60, // Adjust height as needed
              width: 1, // Thickness of the divider
              color: Colors.grey[300], // Divider color
            ),

            // Credit Amount Container
            Text(
              cramount != 0.0 ? '₹ $cramount' : '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red, // Grey text color
              ),
            ),

            // Vertical Divider
            Container(
              height: 40, // Adjust height as needed
              width: 1, // Thickness of the divider
              color: Colors.grey[300], // Divider color
            ),

            // Debit Amount Column
            Column(
              children: [
                Text(
                  dramount != 0.0 ? '₹ $dramount' : '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700], // Green text color for the amount
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
