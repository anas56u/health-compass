import 'package:flutter/material.dart';

class Accessitem extends StatelessWidget {
 final IconData icon;
 final String label;
 final BuildContext context;

  const Accessitem({
      super.key,
      required this.icon,
      required this.label,
      required this.context,
    });
  @override
  Widget build(BuildContext context) {
    return InkWell( 
    onTap: () {
      print('تم الضغط على: $label');
    },
    child: SizedBox(
      width: (MediaQuery.of(context).size.width - 70) / 2, 
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
         
          mainAxisAlignment: MainAxisAlignment.start, 
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            
            const SizedBox(width: 8), 
            Expanded( 
              child: Text(
                label,
                textAlign: TextAlign.right, 
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}