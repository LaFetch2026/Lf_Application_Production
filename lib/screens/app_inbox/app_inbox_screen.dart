// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartech_appinbox/smartech_appinbox.dart';

/// AppInboxScreen — displays Netcore CE App Inbox messages.
///
/// Messages are fetched from the Netcore server on load. If the API call fails
/// (e.g. device is offline), the screen falls back to locally cached messages.
/// No error dialog is shown on failure — the screen silently shows whatever
/// data is available.
class AppInboxScreen extends StatefulWidget {
  const AppInboxScreen({super.key});

  @override
  State<AppInboxScreen> createState() => _AppInboxScreenState();
}

class _AppInboxScreenState extends State<AppInboxScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  /// TRIDs that have already been marked as viewed in this session.
  /// Ensures markMessageAsViewed is called exactly once per message per session.
  final Set<String> _viewedTrids = {};

  // Category filter
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadUnreadCount();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      // Try fetching from Netcore server first
      final result = await SmartechAppinbox().getAppInboxMessagesByApiCall(
        messageLimit: 20,
        smtInboxDataType: 'all',
        categoryList: _selectedCategories,
      );
      _setMessages(result);
    } catch (e) {
      print('⚠️ AppInbox: API call failed ($e) — falling back to local DB');
      // Offline fallback — load from local database
      try {
        final result = await SmartechAppinbox().getAppInboxMessages();
        _setMessages(result);
      } catch (e2) {
        print('⚠️ AppInbox: local DB also failed ($e2) — showing empty state');
        if (mounted) setState(() => _messages = []);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setMessages(dynamic result) {
    if (!mounted) return;
    final List<Map<String, dynamic>> parsed = [];
    if (result is List) {
      for (final item in result) {
        if (item is Map) {
          parsed.add(Map<String, dynamic>.from(item));
        }
      }
    }
    setState(() => _messages = parsed);
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await SmartechAppinbox()
          .getAppInboxMessageCount(smtAppInboxMessageType: 'unread');
      if (mounted) {
        setState(() => _unreadCount = (count is int) ? count : 0);
      }
    } catch (e) {
      print('⚠️ AppInbox: failed to load unread count — $e');
    }
  }

  Future<void> _applyFilter(List<String> categories) async {
    setState(() {
      _selectedCategories = categories;
      _isLoading = true;
    });
    try {
      final result = await SmartechAppinbox()
          .getAppInboxCategoryWiseMessageList(categoryList: categories);
      _setMessages(result);
    } catch (e) {
      print('⚠️ AppInbox: category filter failed ($e)');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Interaction handlers ───────────────────────────────────────────────────

  void _onMessageVisible(String trid) {
    if (_viewedTrids.contains(trid)) return; // idempotent per session
    _viewedTrids.add(trid);
    try {
      SmartechAppinbox().markMessageAsViewed(trid);
    } catch (e) {
      print('⚠️ AppInbox: markMessageAsViewed failed — $e');
    }
  }

  void _onMessageTap(Map<String, dynamic> message) {
    final trid = message['trid']?.toString() ?? '';
    final deeplink = message['deeplink']?.toString() ?? '';
    try {
      SmartechAppinbox().markMessageAsClicked(deeplink, trid);
    } catch (e) {
      print('⚠️ AppInbox: markMessageAsClicked failed — $e');
    }
    if (deeplink.isNotEmpty) {
      Get.toNamed(deeplink);
    }
  }

  void _onMessageDismiss(int index) {
    final message = _messages[index];
    final trid = message['trid']?.toString() ?? '';
    try {
      SmartechAppinbox().markMessageAsDismissed(trid);
    } catch (e) {
      print('⚠️ AppInbox: markMessageAsDismissed failed — $e');
    }
    setState(() => _messages.removeAt(index));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadMessages();
              _loadUnreadCount();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadMessages();
                    await _loadUnreadCount();
                  },
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _AppInboxMessageTile(
                        message: message,
                        onVisible: () {
                          final trid = message['trid']?.toString() ?? '';
                          if (trid.isNotEmpty) _onMessageVisible(trid);
                        },
                        onTap: () => _onMessageTap(message),
                        onDismiss: () => _onMessageDismiss(index),
                      );
                    },
                  ),
                ),
    );
  }
}

// ── Message tile widget ────────────────────────────────────────────────────────

class _AppInboxMessageTile extends StatefulWidget {
  final Map<String, dynamic> message;
  final VoidCallback onVisible;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _AppInboxMessageTile({
    required this.message,
    required this.onVisible,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_AppInboxMessageTile> createState() => _AppInboxMessageTileState();
}

class _AppInboxMessageTileState extends State<_AppInboxMessageTile> {
  bool _hasReportedVisible = false;

  @override
  void initState() {
    super.initState();
    // Report visible on first build (item is in the list = visible)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasReportedVisible && mounted) {
        _hasReportedVisible = true;
        widget.onVisible();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final title = message['title']?.toString() ?? '';
    final body = message['body']?.toString() ?? message['message']?.toString() ?? '';
    final imageUrl = message['imageUrl']?.toString() ?? message['image']?.toString() ?? '';
    final isUnread = (message['status']?.toString() ?? '') != 'viewed' &&
        (message['status']?.toString() ?? '') != 'clicked';

    return Dismissible(
      key: Key(message['trid']?.toString() ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isUnread
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : null,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFEEEEEE)),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread indicator dot
              if (isUnread)
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(width: 16),
              // Optional image
              if (imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 56, height: 56),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
