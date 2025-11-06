import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/core/utils/persistent_logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class DebugLogsScreen extends StatefulWidget {
  const DebugLogsScreen({super.key});

  @override
  State<DebugLogsScreen> createState() => _DebugLogsScreenState();
}

class _DebugLogsScreenState extends State<DebugLogsScreen> {
  String _logs = 'Loading...';
  bool _autoRefresh = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    
    // Auto refresh every 2 seconds
    if (_autoRefresh) {
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted && _autoRefresh) {
          await _loadLogs();
          return true;
        }
        return false;
      });
    }
  }

  Future<void> _loadLogs() async {
    final logs = await persistentLogger.readLogs();
    if (mounted) {
      setState(() {
        _logs = logs;
      });
    }
  }

  Future<void> _clearLogs() async {
    await persistentLogger.clearLogs();
    await _loadLogs();
  }

  Future<void> _shareLogs() async {
    final file = await persistentLogger.getLogFile();
    if (file != null && await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: 'GymBro Timer Debug Logs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          IconButton(
            icon: Icon(_autoRefresh ? AppIcons.pause : AppIcons.play),
            onPressed: () {
              setState(() {
                _autoRefresh = !_autoRefresh;
              });
            },
          ),
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: _loadLogs,
          ),
          IconButton(
            icon: const Icon(AppIcons.share),
            onPressed: _shareLogs,
          ),
          IconButton(
            icon: const Icon(AppIcons.delete),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Text(
                'Timer Debug Logs - Auto-refresh every 2s\n'
                'Look for [KEEP-ALIVE] and [COMPLETION] tags',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                reverse: true, // Show latest logs at bottom
                child: SelectableText(
                  _logs,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Clipboard.setData(ClipboardData(text: _logs));
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text(AppLocalizations.of(context)!.logsCopiedToClipboard)),
      //     );
      //   },
      //   child: const Icon(AppIcons.iconCopy),
      // ),
    );
  }
}
