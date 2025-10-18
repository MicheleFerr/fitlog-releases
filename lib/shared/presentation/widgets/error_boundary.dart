import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Widget che cattura e gestisce errori nei suoi figli
class ErrorBoundary extends StatefulWidget {

  const ErrorBoundary({
    super.key,
    required this.child,
    required this.context,
    this.onError,
  });
  final Widget child;
  final String context;
  final Function(Object error, StackTrace? stack)? onError;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  Object? error;
  StackTrace? stackTrace;

  @override
  void initState() {
    super.initState();
    // Rimosso il log per evitare spam
  }

  void _handleError(Object error, StackTrace? stack) {
    debugPrint('❌ ERROR BOUNDARY CAUGHT ERROR in ${widget.context}:');
    debugPrint('Error: $error');
    debugPrint('Stack trace: $stack');
    
    // Chiama callback custom se fornito
    widget.onError?.call(error, stack);
    
    setState(() {
      hasError = true;
      this.error = error;
      stackTrace = stack;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return _buildErrorWidget();
    }

    // Semplicemente ritorna il child senza modificare ErrorWidget.builder
    // per evitare side effects globali
    try {
      return widget.child;
    } catch (e, stack) {
      // Solo se c'è un errore durante il build, gestiscilo
      if (!hasError) {  // Previeni loop
        _handleError(e, stack);
      }
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error in ${widget.context}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error?.toString() ?? 'Unknown error',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Mostra dettagli completi in debug
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(error.toString()),
                          const SizedBox(height: 16),
                          const Text('Stack Trace:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            stackTrace?.toString() ?? 'No stack trace',
                            style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Show Details'),
            ),
          ],
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Prova a chiudere il modal
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Extension per loggare facilmente errori
extension ErrorLogging on Object {
  void logError(String context, [StackTrace? stack]) {
    debugPrint('❌ ERROR in $context: $this');
    if (stack != null) {
      debugPrint('Stack: $stack');
    }
  }
}