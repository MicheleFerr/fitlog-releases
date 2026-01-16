// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

/// 🎨 Centralized icon constants for GymBro app
///
/// **Usage**:
/// ```dart
/// SemanticIcon(
///   icon: AppIcons.workout,
///   semanticLabel: 'Workout',
/// )
/// SemanticIcon(
///   icon: AppIcons.timer,
///   semanticLabel: 'Timer',
/// )
/// SemanticIcon(
///   icon: AppIcons.complete,
///   semanticLabel: 'Complete',
/// )
/// ```
///
/// **Benefits**:
/// - ✅ Single source of truth for all icons
/// - ✅ Easy refactoring (change 1 line → entire app updates)
/// - ✅ Type-safe icon references
/// - ✅ IDE autocomplete support
/// - ✅ Semantic naming (workout vs fitness_center)
///
/// **Guidelines**:
/// - Use semantic names (e.g., `workout` not `fitness_center`)
/// - Group by feature/category
/// - Document when icon changes meaning across contexts
///
/// See: `docs/ICON_USAGE_REPORT.md` for full analysis
class AppIcons {
  AppIcons._(); // Private constructor to prevent instantiation

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🏋️ CORE FITNESS (Most Used)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 🏋️ Workout/Exercise (316 uses - most used icon)
  static const IconData workout = Icons.fitness_center;

  /// 🏃 Cardio/Running
  static const IconData cardio = Icons.directions_run;

  /// 🤸 Gymnastics/Bodyweight
  static const IconData gymnastics = Icons.sports_gymnastics;

  /// 🤸 Sports gymnastics (alias for gymnastics)
  static const IconData sportsGymnastics = Icons.sports_gymnastics;

  /// 🧘 Flexibility/Yoga
  static const IconData flexibility = Icons.self_improvement;

  /// ♿ Accessibility/Mobility
  static const IconData accessibility = Icons.accessibility_new;

  /// ⚖️ Weight tracking
  static const IconData weight = Icons.monitor_weight;

  /// 🌱 Beginner level
  static const IconData beginner = Icons.local_florist;

  /// 💪 Expert level
  static const IconData expert = Icons.military_tech;

  /// 📋 Workout template
  static const IconData template = Icons.description;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ⏱️ TIMER & SCHEDULING
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ⏱️ Timer (active)
  static const IconData timer = Icons.timer;

  /// ⏸️ Timer (paused/disabled)
  static const IconData timerOff = Icons.timer_off;

  /// 📅 Calendar/Date
  static const IconData calendar = Icons.calendar_today;

  /// 🗓️ Calendar month view
  static const IconData calendarMonth = Icons.calendar_month;

  /// 🕐 Schedule/Time
  static const IconData schedule = Icons.schedule;

  /// ⏰ Access time
  static const IconData clock = Icons.access_time;

  /// 📜 History
  static const IconData history = Icons.history;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ✅ SUCCESS & VALIDATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ✅ Complete/Confirmed (filled)
  static const IconData complete = Icons.check_circle;

  /// ✅ Complete (outline)
  static const IconData completeOutline = Icons.check_circle_outline;

  /// ✓ Check mark (simple)
  static const IconData check = Icons.check;

  /// ✅ All done
  static const IconData allDone = Icons.done_all;

  /// ✅ Done all (alias for allDone)
  static const IconData doneAll = Icons.done_all;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 📈 PROGRESS & ANALYTICS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 📈 Trend up/Progress
  static const IconData trendUp = Icons.trending_up;

  /// 📉 Trend down/Decline
  static const IconData trendDown = Icons.trending_down;

  /// → Trend flat/Stable
  static const IconData trendFlat = Icons.trending_flat;

  /// 📊 Analytics
  static const IconData analytics = Icons.analytics;

  /// 📊 Bar chart
  static const IconData barChart = Icons.bar_chart;

  /// 📈 Line chart
  static const IconData lineChart = Icons.show_chart;

  /// 💡 Insights
  static const IconData insights = Icons.insights;

  /// ⚡ Speed/Performance
  static const IconData speed = Icons.speed;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎮 GAMIFICATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ⭐ Star/Rating/Favorite
  static const IconData star = Icons.star;

  /// ☆ Star outline
  static const IconData starOutline = Icons.star_border;

  /// 🏆 Achievement/Trophy
  static const IconData achievement = Icons.emoji_events;

  /// 🔥 Streak/Fire
  static const IconData streak = Icons.local_fire_department;

  /// 🎉 Celebration
  static const IconData celebration = Icons.celebration;

  /// 👍 Thumbs up
  static const IconData thumbUp = Icons.thumb_up;

  /// 👎 Thumbs down
  static const IconData thumbDown = Icons.thumb_down;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ❌ UI CONTROLS & NAVIGATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ❌ Close/Dismiss
  static const IconData close = Icons.close;

  /// ← Back
  static const IconData back = Icons.arrow_back;

  /// → Forward
  static const IconData forward = Icons.forward;

  /// → Forward iOS style
  static const IconData forwardIos = Icons.arrow_forward_ios;

  /// ▼ Expand more
  static const IconData expandMore = Icons.expand_more;

  /// ▲ Expand less
  static const IconData expandLess = Icons.expand_less;

  /// ⛶ Fullscreen
  static const IconData fullscreen = Icons.fullscreen;

  /// ⛶ Exit fullscreen
  static const IconData fullscreenExit = Icons.fullscreen_exit;

  /// › Chevron right
  static const IconData chevronRight = Icons.chevron_right;

  /// ‹ Chevron left
  static const IconData chevronLeft = Icons.chevron_left;

  /// ⊗ Clear
  static const IconData clear = Icons.clear;

  /// − Remove
  static const IconData remove = Icons.remove;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ℹ️ INFO & FEEDBACK
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ℹ️ Info
  static const IconData info = Icons.info;

  /// ⚠️ Error
  static const IconData error = Icons.error;

  /// ⚠️ Warning
  static const IconData warning = Icons.warning;

  /// ❓ Help
  static const IconData help = Icons.help;

  /// 💡 Tip/Suggestion
  static const IconData tip = Icons.lightbulb_outline;

  /// 💡 Lightbulb (filled)
  static const IconData lightbulb = Icons.lightbulb;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ✏️ ACTIONS & EDITING
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ✏️ Edit
  static const IconData edit = Icons.edit;

  /// ➕ Add
  static const IconData add = Icons.add;

  /// ➕ Add circle outline
  static const IconData addCircleOutline = Icons.add_circle_outline;

  /// 🗑️ Delete
  static const IconData delete = Icons.delete;

  /// 🗑️ Delete outline
  static const IconData deleteOutline = Icons.delete_outline;

  /// 🔄 Refresh
  static const IconData refresh = Icons.refresh;

  /// 💾 Save
  static const IconData save = Icons.save;

  /// 📋 Copy
  static const IconData copy = Icons.copy;

  /// 📋 Paste
  static const IconData paste = Icons.content_paste;

  /// ↩️ Undo
  static const IconData undo = Icons.undo;

  /// ↪️ Redo
  static const IconData redo = Icons.redo;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 👥 PEOPLE & SOCIAL
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 👤 Person/Profile
  static const IconData person = Icons.person;

  /// 👥 People/Group
  static const IconData people = Icons.people;

  /// 👥 People outline
  static const IconData peopleOutline = Icons.people_outline;

  /// ✅ Verified
  static const IconData verified = Icons.verified;

  /// 🤝 Handshake
  static const IconData handshake = Icons.handshake;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ▶️ MEDIA & PLAYBACK
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ▶️ Play
  static const IconData play = Icons.play_arrow;

  /// ⏸️ Pause
  static const IconData pause = Icons.pause;

  /// ⏹️ Stop
  static const IconData stop = Icons.stop;

  /// ⏭️ Skip next
  static const IconData skipNext = Icons.skip_next;

  /// 🔁 Repeat
  static const IconData repeat = Icons.repeat;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔍 SEARCH
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 🔍 Search
  static const IconData search = Icons.search;

  /// 🔍 Search off
  static const IconData searchOff = Icons.search_off;

  /// 🎛️ Filter
  static const IconData filter = Icons.filter;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ⚙️ SETTINGS & ADMIN
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ⚙️ Settings
  static const IconData settings = Icons.settings;

  /// 🛡️ Admin
  static const IconData admin = Icons.admin_panel_settings;

  /// 🔒 Lock
  static const IconData lock = Icons.lock;

  /// 🔓 Unlock
  static const IconData unlock = Icons.lock_open;

  /// 🔔 Notifications
  static const IconData notifications = Icons.notifications;

  /// 🎨 Theme/Palette
  static const IconData theme = Icons.palette;

  /// 🌍 Language
  static const IconData language = Icons.language;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 👑 PREMIUM & IAP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 👑 Premium/Workspace premium
  static const IconData premium = Icons.workspace_premium;

  /// 🎁 Gift card
  static const IconData gift = Icons.card_giftcard;

  /// 🚀 Rocket (launch)
  static const IconData rocket = Icons.rocket_launch;

  /// ✨ Auto awesome (premium feature)
  static const IconData autoAwesome = Icons.auto_awesome;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 📱 MISCELLANEOUS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 📤 Share
  static const IconData share = Icons.share;

  /// 📥 Download
  static const IconData download = Icons.download;

  /// 📤 Upload
  static const IconData upload = Icons.upload;

  /// 📷 Camera
  static const IconData camera = Icons.camera_alt;

  /// 🔄 Switch camera (front/back)
  static const IconData cameraSwitch = Icons.cameraswitch;

  /// 🎚️ Opacity/Transparency
  static const IconData opacity = Icons.opacity;

  /// 🖼️ Image
  static const IconData image = Icons.image;

  /// 📄 Document
  static const IconData document = Icons.description;

  /// 🔗 Link
  static const IconData link = Icons.link;

  /// 🔗⛔ Link off (disconnected)
  static const IconData linkOff = Icons.link_off;

  /// 📱 QR Code
  static const IconData qrCode = Icons.qr_code;

  /// ⌚ Apple Watch
  static const IconData watch = Icons.watch;

  /// 🏠 Home
  static const IconData home = Icons.home;

  /// 📧 Email
  static const IconData email = Icons.email;

  /// 📍 Location
  static const IconData location = Icons.location_on;

  /// ☁️ Cloud
  static const IconData cloud = Icons.cloud;

  /// ☁️ Cloud sync
  static const IconData cloudSync = Icons.cloud_sync;

  /// 💬 Chat/Comment
  static const IconData chat = Icons.chat;

  /// ☰ Menu
  static const IconData menu = Icons.menu;

  /// ⋮ More vertical
  static const IconData moreVert = Icons.more_vert;

  /// ··· More horizontal
  static const IconData moreHoriz = Icons.more_horiz;

  /// 👁️ Visibility
  static const IconData visibility = Icons.visibility;

  /// 👁️‍🗨️ Visibility off
  static const IconData visibilityOff = Icons.visibility_off;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎨 THEME & APPEARANCE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ☀️ Light mode
  static const IconData lightMode = Icons.light_mode;

  /// 🌙 Dark mode
  static const IconData darkMode = Icons.dark_mode;

  /// 🎨 Color lens
  static const IconData colorLens = Icons.color_lens;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🧠 SMART FEATURES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 🧠 Psychology/AI
  static const IconData ai = Icons.psychology;

  /// 🔬 Science
  static const IconData science = Icons.science;

  /// 🎓 School/Education
  static const IconData education = Icons.school;

  /// 🧪 Experiment
  static const IconData experiment = Icons.science_outlined;

  /// 🎤 Voice input/Microphone (AI Coach Phase 3.1)
  static const IconData mic = Icons.mic;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎨 SEMANTIC DUPLICATE VARIANTS (Phase 2)
  // High-value variants (≥10 total usages) - Consolidating scattered icon styles
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // close variants (total: 85 usages)
  static const IconData closeRounded = Icons.close_rounded;

  // repeat variants (total: 56 usages)
  static const IconData repeatRounded = Icons.repeat_rounded;

  // star variants (total: 56 usages)
  static const IconData starRounded = Icons.star_rounded;

  // edit variants (total: 56 usages)
  static const IconData editNoteRounded = Icons.edit_note_rounded;
  static const IconData editRounded = Icons.edit_rounded;

  // error_outline variants (total: 54 usages)
  static const IconData errorOutlineRounded = Icons.error_rounded;

  // calendar_today variants (total: 41 usages)
  static const IconData calendarTodayOutlined = Icons.calendar_today_outlined;

  // history variants (total: 37 usages)
  static const IconData historyOutlined = Icons.history_outlined;
  static const IconData historyRounded = Icons.history_rounded;

  // check variants (total: 36 usages)
  static const IconData checkRounded = Icons.check_rounded;

  // analytics variants (total: 36 usages)
  static const IconData analyticsOutlined = Icons.analytics_outlined;
  static const IconData analyticsRounded = Icons.analytics_rounded;

  // emoji_events variants (total: 35 usages)
  static const IconData emojiEventsOutlined = Icons.emoji_events_outlined;

  // play_arrow variants (total: 34 usages)
  static const IconData playArrowRounded = Icons.play_circle_filled;

  // search variants (total: 29 usages)
  static const IconData searchOutlined = Icons.search_outlined;

  // schedule variants (total: 28 usages)
  static const IconData scheduleOutlined = Icons.schedule_outlined;
  static const IconData scheduleRounded = Icons.schedule_rounded;

  // warning variants (total: 24 usages)
  static const IconData warningRounded = Icons.warning_rounded;

  // speed variants (total: 22 usages)
  static const IconData speedOutlined = Icons.speed_outlined;

  // people variants (total: 22 usages)
  static const IconData peopleRounded = Icons.people_rounded;

  // bar_chart variants (total: 21 usages)
  static const IconData barChartOutlined = Icons.bar_chart_outlined;

  // chevron_right variants (total: 20 usages)
  static const IconData chevronRightRounded = Icons.chevron_right_rounded;

  // auto_awesome variants (total: 18 usages)
  static const IconData autoAwesomeOutlined = Icons.auto_awesome_outlined;

  // info variants (total: 17 usages)
  static const IconData infoOutlined = Icons.info;

  // settings variants (total: 16 usages)
  static const IconData settingsOutlined = Icons.settings_outlined;
  static const IconData settingsRounded = Icons.settings_rounded;

  // rocket_launch variants (total: 15 usages)
  static const IconData rocketLaunchRounded = Icons.rocket_launch_rounded;

  // calendar_month variants (total: 14 usages)
  static const IconData calendarMonthOutlined = Icons.calendar_month_outlined;
  static const IconData calendarMonthRounded = Icons.calendar_month_rounded;

  // insights variants (total: 13 usages)
  static const IconData insightsOutlined = Icons.insights_outlined;
  static const IconData insightsRounded = Icons.insights_rounded;

  // whatshot variants (total: 13 usages)
  static const IconData whatshotOutlined = Icons.whatshot_outlined;

  // cancel variants (total: 13 usages)
  static const IconData cancelOutlined = Icons.cancel_outlined;
  static const IconData cancelRounded = Icons.cancel_rounded;

  // arrow_forward variants (total: 12 usages)
  static const IconData arrowForwardRounded = Icons.forward_rounded;

  // pause variants (total: 11 usages)
  static const IconData pauseRounded = Icons.pause_rounded;

  // verified variants (total: 10 usages)
  static const IconData verifiedOutlined = Icons.verified_outlined;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎯 PHASE 3: COMPLETE CENTRALIZATION
  // All remaining icons from the codebase (303 total)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  // ACTION (18 icons)
  static const IconData contentCopyRounded = Icons.copy_rounded;
  static const IconData create = Icons.create;
  static const IconData dragHandle = Icons.drag_handle;
  static const IconData dragIndicator = Icons.drag_indicator;
  static const IconData editCalendar = Icons.edit_calendar;
  static const IconData editNote = Icons.edit_note;
  static const IconData filter9Plus = Icons.filter_9_plus;
  static const IconData filterAltOff = Icons.filter_alt_off;
  static const IconData filterListOutlined = Icons.filter_outlined;
  static const IconData mobileScreenShare = Icons.mobile_screen_share;
  static const IconData noteAdd = Icons.note_add;
  static const IconData personAdd = Icons.person_add;
  static const IconData removeCircleOutline = Icons.remove_circle_outline;
  static const IconData saveAlt = Icons.save_alt;
  static const IconData shareOutlined = Icons.share_outlined;
  static const IconData sort = Icons.sort;

  // ANALYTICS (9 icons)
  static const IconData autoGraph = Icons.auto_graph;
  static const IconData bubbleChart = Icons.bubble_chart;
  static const IconData gMobiledata = Icons.g_mobiledata;
  static const IconData pieChart = Icons.pie_chart;
  static const IconData stackedLineChart = Icons.stacked_line_chart;
  static const IconData tableChart = Icons.table_chart;
  static const IconData trendingNeutral = Icons.trending_neutral;
  static const IconData trendingUpRounded = Icons.trending_up;

  // COMMUNICATION (13 icons)
  static const IconData alternateEmail = Icons.alternate_email;
  static const IconData attachFile = Icons.attach_file;
  static const IconData chatBubbleOutline = Icons.chat_bubble_outline;
  static const IconData commentOutlined = Icons.comment_outlined;
  static const IconData commentsDisabledOutlined = Icons.comments_disabled_outlined;
  static const IconData message = Icons.message;
  static const IconData notificationsActive = Icons.notifications_active;
  static const IconData notificationsNone = Icons.notifications_none;
  static const IconData notificationsOffOutlined = Icons.notifications_off_outlined;
  static const IconData notificationsOutlined = Icons.notifications_outlined;
  static const IconData send = Icons.send;
  static const IconData phone = Icons.phone;
  static const IconData business = Icons.business;

  // CONTENT (11 icons)
  static const IconData brokenImage = Icons.broken_image;
  static const IconData fileDownload = Icons.file_download;
  static const IconData fileUpload = Icons.file_upload;
  static const IconData fileUploadOutlined = Icons.file_upload_outlined;
  static const IconData folder = Icons.folder;
  static const IconData folderOutlined = Icons.folder_outlined;
  static const IconData folderOpen = Icons.folder_open;
  static const IconData createNewFolder = Icons.create_new_folder;
  static const IconData imageNotSupported = Icons.image_not_supported;
  static const IconData photoCamera = Icons.photo_camera;
  static const IconData photoLibrary = Icons.photo_library;
  static const IconData uploadFile = Icons.upload_file;
  static const IconData videoLibraryOutlined = Icons.video_library_outlined;

  // EMOJI (1 icons)

  // FITNESS (8 icons)
  static const IconData fitnessCenterOutlined = Icons.fitness_center;
  static const IconData fitnessCenterRounded = Icons.fitness_center;
  static const IconData healthAndSafety = Icons.health_and_safety;
  static const IconData sports = Icons.sports;
  static const IconData sportsFootball = Icons.sports_football;
  static const IconData sportsHandball = Icons.sports_handball;
  static const IconData sportsMartialArts = Icons.sports_martial_arts;
  static const IconData sportsMma = Icons.sports_mma;

  // LOCATION (4 icons)
  static const IconData gpsFixed = Icons.gps_fixed;
  static const IconData locationCity = Icons.location_city;
  static const IconData myLocation = Icons.my_location;
  static const IconData zoomOutMap = Icons.zoom_out_map;

  // MEDIA (9 icons)
  static const IconData pauseCircle = Icons.pause_circle;
  static const IconData pauseCircleOutline = Icons.pause_circle_outline;
  static const IconData playCircle = Icons.play_circle;
  static const IconData playCircleFilled = Icons.play_circle_filled;
  static const IconData playCircleOutline = Icons.play_circle_outline;
  static const IconData replay = Icons.replay;
  static const IconData skipNextRounded = Icons.skip_next_rounded;
  static const IconData volumeUp = Icons.volume_up;
  static const IconData volumeOff = Icons.volume_off;

  // MISC (151 icons)
  static const IconData acUnit = Icons.ac_unit;
  static const IconData accessible = Icons.accessible;
  static const IconData airlineSeatFlat = Icons.airline_seat_flat;
  static const IconData airlineSeatReclineNormal = Icons.airline_seat_recline_normal;
  static const IconData allInclusive = Icons.all_inclusive;
  static const IconData altRoute = Icons.alt_route;
  static const IconData animation = Icons.animation;
  static const IconData apple = Icons.apple;
  static const IconData apps = Icons.apps;
  static const IconData architecture = Icons.architecture;
  static const IconData archive = Icons.archive;
  static const IconData article = Icons.article;
  static const IconData articleOutlined = Icons.article_outlined;
  static const IconData assignment = Icons.assignment;
  static const IconData assignmentOutlined = Icons.assignment_outlined;
  static const IconData autoFixHigh = Icons.auto_fix_high;
  static const IconData autoMode = Icons.auto_mode;
  static const IconData badge = Icons.badge;
  static const IconData balance = Icons.balance;
  static const IconData bed = Icons.bed;
  static const IconData bolt = Icons.bolt;
  static const IconData bugReport = Icons.bug_report;
  static const IconData calculate = Icons.calculate;
  static const IconData calculateOutlined = Icons.calculate_outlined;
  static const IconData calculateRounded = Icons.calculate_rounded;
  static const IconData category = Icons.category;
  static const IconData centerFocusStrong = Icons.center_focus_strong;
  static const IconData circle = Icons.circle;
  static const IconData circleOutlined = Icons.circle_outlined;
  static const IconData clearAll = Icons.clear_all;
  static const IconData cloudDownload = Icons.cloud_download;
  static const IconData cloudOff = Icons.cloud_off;
  static const IconData cloudSyncRounded = Icons.cloud_sync_rounded;
  static const IconData code = Icons.code;
  static const IconData construction = Icons.construction;
  static const IconData crop169 = Icons.crop_16_9;
  static const IconData cropPortrait = Icons.crop_portrait;
  static const IconData cropSquare = Icons.crop_square;
  static const IconData dashboard = Icons.dashboard;
  static const IconData dashboardCustomize = Icons.dashboard_customize;
  static const IconData dashboardOutlined = Icons.dashboard_outlined;
  static const IconData dialpad = Icons.dialpad;
  static const IconData diamond = Icons.diamond;
  static const IconData directionsWalk = Icons.directions_walk;
  static const IconData donutLarge = Icons.donut_large;
  static const IconData downloadForOffline = Icons.download_for_offline;
  static const IconData equalizer = Icons.equalizer;
  static const IconData explore = Icons.explore;
  static const IconData exploreOff = Icons.explore_off;
  static const IconData female = Icons.female;
  static const IconData fiberManualRecord = Icons.fiber_manual_record;
  static const IconData flag = Icons.flag;
  static const IconData flagCircle = Icons.flag_circle;
  static const IconData flagOutlined = Icons.flag_outlined;
  static const IconData flashOn = Icons.flash_on;
  static const IconData flight = Icons.flight;
  static const IconData formatListBulleted = Icons.format_list_bulleted;
  static const IconData formatListNumbered = Icons.format_list_numbered;
  static const IconData formatQuote = Icons.format_quote;
  static const IconData formatSize = Icons.format_size;
  static const IconData shortText = Icons.short_text;
  static const IconData palette = Icons.palette;
  static const IconData functions = Icons.functions;
  static const IconData grid4x4 = Icons.grid_4x4;
  static const IconData gridOn = Icons.grid_on;
  static const IconData gridView = Icons.grid_view;
  static const IconData healing = Icons.healing;
  static const IconData hexagonOutlined = Icons.hexagon_outlined;
  static const IconData horizontalRule = Icons.horizontal_rule;
  static const IconData hotel = Icons.hotel;
  static const IconData hourglassEmpty = Icons.hourglass_empty;
  static const IconData howToVote = Icons.how_to_vote;
  static const IconData inbox = Icons.inbox;
  static const IconData inventory2 = Icons.inventory_2;
  static const IconData inventory2Outlined = Icons.inventory_2_outlined;
  static const IconData label = Icons.label;
  static const IconData labelOutline = Icons.label_outline;
  static const IconData layers = Icons.layers;
  static const IconData leaderboard = Icons.leaderboard;
  static const IconData libraryBooks = Icons.library_books;
  static const IconData list = Icons.list;
  static const IconData listAlt = Icons.list_alt;
  static const IconData logout = Icons.logout;
  static const IconData looks = Icons.looks;
  static const IconData looks3 = Icons.looks_3;
  static const IconData looks6 = Icons.looks_6;
  static const IconData looksOne = Icons.looks_one;
  static const IconData male = Icons.male;
  static const IconData militaryTech = Icons.military_tech;
  static const IconData mobileOff = Icons.mobile_off;
  static const IconData monitorWeightOutlined = Icons.monitor_weight_outlined;
  static const IconData newReleases = Icons.new_releases;
  static const IconData nightlightRound = Icons.nightlight_round;
  static const IconData north = Icons.north;
  static const IconData note = Icons.note;
  static const IconData noteAlt = Icons.note_alt;
  static const IconData notes = Icons.notes;
  static const IconData openInNew = Icons.open_in_new;
  static const IconData percent = Icons.percent;
  static const IconData pictureAsPdf = Icons.picture_as_pdf;
  static const IconData pictureInPictureAlt = Icons.picture_in_picture_alt;
  static const IconData policyOutlined = Icons.policy_outlined;
  static const IconData preview = Icons.preview;
  static const IconData print = Icons.print;
  static const IconData privacyTipRounded = Icons.privacy_tip_rounded;
  static const IconData rateReview = Icons.rate_review;
  static const IconData recommend = Icons.recommend;
  static const IconData reportProblem = Icons.report_problem;
  static const IconData reportProblemOutlined = Icons.report_problem_outlined;
  static const IconData rowing = Icons.rowing;
  static const IconData scale = Icons.scale;
  static const IconData screenLockPortrait = Icons.screen_lock_portrait;
  static const IconData schoolOutlined = Icons.school_outlined;
  static const IconData selectAll = Icons.select_all;
  static const IconData shuffle = Icons.shuffle;
  static const IconData sick = Icons.sick;
  static const IconData south = Icons.south;
  static const IconData spa = Icons.spa;
  static const IconData storage = Icons.storage;
  static const IconData straighten = Icons.straighten;
  static const IconData tag = Icons.local_offer;
  static const IconData package = Icons.inventory_2;
  static const IconData support = Icons.support;
  static const IconData supportAgent = Icons.support_agent;
  static const IconData swapHoriz = Icons.swap_horiz;
  static const IconData swapHorizRounded = Icons.swap_horiz_rounded;
  static const IconData swapVert = Icons.swap_vert;
  static const IconData compare = Icons.compare;
  static const IconData swipe = Icons.swipe;
  static const IconData sync = Icons.sync;
  static const IconData syncAlt = Icons.sync_alt;
  static const IconData title = Icons.title;
  static const IconData toggleOff = Icons.toggle_off;
  static const IconData toggleOn = Icons.toggle_on;
  static const IconData touchApp = Icons.touch_app;
  static const IconData trackChanges = Icons.track_changes;
  static const IconData translate = Icons.translate;
  static const IconData unarchive = Icons.unarchive;
  static const IconData unfoldLess = Icons.unfold_less;
  static const IconData vibration = Icons.vibration;
  static const IconData viewAgenda = Icons.view_agenda;
  static const IconData viewList = Icons.view_list;
  static const IconData viewCompact = Icons.view_compact;
  static const IconData viewComfy = Icons.view_comfy;
  static const IconData viewDetailed = Icons.view_agenda;
  static const IconData expand = Icons.unfold_more;
  static const IconData export = Icons.upload_file;
  static const IconData waves = Icons.waves;
  static const IconData wavingHand = Icons.waving_hand;
  static const IconData wbSunny = Icons.wb_sunny;
  static const IconData wbSunnyOutlined = Icons.wb_sunny_outlined;
  static const IconData wbTwilight = Icons.wb_twilight;
  static const IconData nightsStay = Icons.nights_stay;
  static const IconData alarmOn = Icons.alarm_on;
  static const IconData whatshot = Icons.whatshot;
  static const IconData widgets = Icons.widgets;
  static const IconData work = Icons.work;
  static const IconData workspaces = Icons.workspaces;

  // MONEY (1 icons)
  static const IconData restore = Icons.restore;

  // NAVIGATION (19 icons)
  static const IconData arrowBackIos = Icons.arrow_back_ios;
  static const IconData arrowBackIosNew = Icons.arrow_back_ios_new;
  static const IconData arrowBackIosRounded = Icons.arrow_back_ios_rounded;
  static const IconData arrowDownward = Icons.arrow_downward;
  static const IconData arrowDropDown = Icons.arrow_drop_down;
  static const IconData arrowUpward = Icons.arrow_upward;
  static const IconData backup = Icons.backup;
  static const IconData backupRounded = Icons.backup_rounded;
  static const IconData doubleArrow = Icons.double_arrow;
  static const IconData feedback = Icons.feedback;
  static const IconData feedbackOutlined = Icons.feedback_outlined;
  static const IconData keyboardArrowDown = Icons.keyboard_arrow_down;
  static const IconData keyboardArrowDownRounded = Icons.keyboard_arrow_down_rounded;
  static const IconData keyboardArrowUp = Icons.keyboard_arrow_up;
  static const IconData menuBook = Icons.menu_book;
  static const IconData menuBookOutlined = Icons.menu_book_outlined;

  // SECURITY (7 icons)
  static const IconData block = Icons.block;
  static const IconData keyboard = Icons.keyboard;
  static const IconData lockOutline = Icons.lock_outline;
  static const IconData security = Icons.security;
  static const IconData securityRounded = Icons.security_rounded;
  static const IconData shield = Icons.shield;
  static const IconData shieldOutlined = Icons.shield_outlined;

  // SETTINGS (5 icons)
  static const IconData build = Icons.build;
  static const IconData buildCircle = Icons.build_circle;
  static const IconData developerMode = Icons.developer_mode;
  static const IconData settingsApplications = Icons.settings_applications;
  static const IconData tune = Icons.tune;

  // SOCIAL (11 icons)
  static const IconData favorite = Icons.favorite;
  static const IconData favoriteBorder = Icons.favorite_border;
  static const IconData public = Icons.public;
  static const IconData starHalf = Icons.star_half;
  static const IconData stars = Icons.stars;
  static const IconData starsRounded = Icons.stars_rounded;
  static const IconData thumbDownOutlined = Icons.thumb_down_outlined;
  static const IconData thumbUpOutlined = Icons.thumb_up_outlined;
  static const IconData bookmark = Icons.bookmark_border;
  static const IconData bookmarkFilled = Icons.bookmark;
  static const IconData comment = Icons.comment_outlined;

  // STATUS (21 icons)
  static const IconData cancel = Icons.cancel;
  static const IconData checkCircle = Icons.check_circle;
  static const IconData wifiOff = Icons.wifi_off;
  static const IconData checkBox = Icons.check_box;
  static const IconData checkBoxOutlineBlank = Icons.check_box_outline_blank;
  static const IconData checklist = Icons.checklist;
  static const IconData cloudDone = Icons.cloud_done;
  static const IconData cloudDoneRounded = Icons.cloud_done_rounded;
  static const IconData done = Icons.done;
  static const IconData downloadDone = Icons.download_done;
  static const IconData pending = Icons.pending;
  static const IconData pendingActions = Icons.pending_actions;
  static const IconData priorityHigh = Icons.priority_high;
  static const IconData radioButtonChecked = Icons.radio_button_checked;
  static const IconData radioButtonUnchecked = Icons.radio_button_unchecked;
  static const IconData verifiedUser = Icons.verified_user;
  static const IconData verifiedUserOutlined = Icons.verified_user_outlined;
  static const IconData warningAmber = Icons.warning_amber;
  static const IconData warningAmberRounded = Icons.warning_amber_rounded;

  // SYSTEM (4 icons)
  static const IconData batteryAlert = Icons.battery_alert;
  static const IconData batteryChargingFull = Icons.battery_charging_full;
  static const IconData phoneAndroid = Icons.phone_android;
  static const IconData phoneIphone = Icons.phone_iphone;

  // TIMER_DATE (18 icons)
  static const IconData bedtime = Icons.bedtime;
  static const IconData calendarViewDay = Icons.calendar_view_day;
  static const IconData calendarViewMonth = Icons.calendar_view_month;
  static const IconData calendarViewWeek = Icons.calendar_view_week;
  static const IconData dateRange = Icons.date_range;
  static const IconData dateRangeRounded = Icons.date_range_rounded;
  static const IconData event = Icons.event;
  static const IconData eventAvailable = Icons.event_available;
  static const IconData eventBusy = Icons.event_busy;
  static const IconData eventNote = Icons.event_note;
  static const IconData lockClock = Icons.lock_clock;
  static const IconData systemUpdate = Icons.system_update;
  static const IconData timeline = Icons.timeline;
  static const IconData timerOffOutlined = Icons.timer_off_outlined;
  static const IconData tipsAndUpdates = Icons.tips_and_updates;
  static const IconData today = Icons.today;
  static const IconData todayRounded = Icons.today_rounded;
  static const IconData update = Icons.update;

  // USER_PROFILE (1 icons)
  static const IconData personOutline = Icons.person_outline;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔄 ALIASES (For backwards compatibility after merge)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// ℹ️ Info icon (alias for info)
  static const IconData infoIcon = Icons.info;

  /// 🔄 Sync icon (alias for sync)
  static const IconData syncIcon = Icons.sync;

  /// ☁️ Cloud upload (alias for upload)
  static const IconData cloudUpload = Icons.upload;

  /// 📋 Copy icon (alias for copy)
  static const IconData iconCopy = Icons.copy;

  /// 📦 Miscellaneous/Category
  static const IconData misc = Icons.category;

  /// ➕ Add circle (filled)
  static const IconData addCircle = Icons.add_circle;

  /// 📝 Title icon (alias for title)
  static const IconData titleIcon = Icons.title;

  /// ⭐ Star half icon (alias for starHalf)
  static const IconData starHalfIcon = Icons.star_half;

  /// ⬇️ Expand icon (alias for expand)
  static const IconData expandIcon = Icons.unfold_more;

  /// ♿ Accessibility icon (alias for accessibility)
  static const IconData accessibilityIcon = Icons.accessibility_new;

  // ========================================
  // 🆕 Additional Icons (Added for Coverage)
  // ========================================

  /// 🧠 Psychology/AI
  static const IconData psychology = Icons.psychology;

  /// 📉 Trending down
  static const IconData trendingDown = Icons.trending_down;

  /// → Trending flat
  static const IconData trendingFlat = Icons.trending_flat;

  /// 🔥 Fire/Calories
  static const IconData localFireDepartment = Icons.local_fire_department;

  /// ❓ Help outline
  static const IconData helpOutline = Icons.help;

  /// ⏰ Access time/Clock
  static const IconData accessTime = Icons.access_time;

  /// → Arrow forward iOS
  static const IconData arrowForwardIos = Icons.arrow_forward_ios;

  /// 🏃 Directions run/Cardio
  static const IconData directionsRun = Icons.directions_run;

  /// 🏠 Home outlined
  static const IconData homeOutlined = Icons.home_outlined;

  /// 🏋️ Workout outlined (fitness center)
  static const IconData workoutOutlined = Icons.fitness_center_outlined;

  /// 👤 Profile outlined
  static const IconData profileOutlined = Icons.person_outline;

  /// 📐 Body measurements (ruler/straighten)
  static const IconData bodyMeasurements = Icons.straighten;

  /// 🏃 Exercise (single exercise icon)
  static const IconData exercise = Icons.sports_gymnastics;

  /// 💡 Lightbulb outline
  static const IconData lightbulbOutline = Icons.lightbulb_outline;

  /// ⏸️ Pause circle filled
  static const IconData pauseCircleFilled = Icons.pause_circle_filled;

  /// 🧘 Self improvement/Mindfulness
  static const IconData selfImprovement = Icons.self_improvement;

  /// 📈 Show chart/Line chart
  static const IconData showChart = Icons.show_chart;

  /// ☆ Star border/Outline
  static const IconData starBorder = Icons.star_border;

  /// 🎓 School/Education
  static const IconData school = Icons.school;

  /// 🔀 Merge/Consolidate exercises
  static const IconData merge = Icons.merge;

  /// ⬇️ Arrow down
  static const IconData arrowDown = Icons.arrow_downward;

  /// 🏆 Trophy/Personal record
  static const IconData trophy = Icons.emoji_events;

  // ========================================
  // 🔄 Base Icon Variants (snake_case mappings)
  // ========================================

  /// 🏋️ Fitness center (base variant)
  static const IconData fitnessCenter = Icons.fitness_center;

  /// 🏆 Emoji events/Trophy (base variant)
  static const IconData emojiEvents = Icons.emoji_events;

  /// ⚠️ Error outline (base variant)
  static const IconData errorOutline = Icons.error;

  /// ℹ️ Info outline (base variant)
  static const IconData infoOutline = Icons.info;

  /// 📈 Trending up (base variant)
  static const IconData trendingUp = Icons.trending_up;

  /// 📈 Trending (alias for trendingUp)
  static const IconData trending = Icons.trending_up;

  /// 📤 Publish/Upload
  static const IconData publish = Icons.publish;

  /// ▶️ Play arrow (base variant)
  static const IconData playArrow = Icons.play_arrow;

  /// 🚀 Rocket launch (base variant)
  static const IconData rocketLaunch = Icons.rocket_launch;

  /// ♿ Accessibility new (base variant)
  static const IconData accessibilityNew = Icons.accessibility_new;

  /// ← Arrow back (base variant)
  static const IconData arrowBack = Icons.arrow_back;

  /// 📅 Calendar today (base variant)
  static const IconData calendarToday = Icons.calendar_today;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🆕 ADDITIONAL MAPPINGS (for design system compliance)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 🤖 Android
  static const IconData android = Icons.android;

  /// ➡️ Arrow forward
  static const IconData arrowForward = Icons.arrow_forward;

  /// 📏 Height
  static const IconData height = Icons.height;

  /// 🌙 Nightlight
  static const IconData nightlight = Icons.nightlight;

  /// ▶️ Play rounded
  static const IconData playRounded = Icons.play_arrow_rounded;

  /// 🌡️ Thermostat
  static const IconData thermostat = Icons.thermostat;

  /// ⏱️ Timer outlined
  static const IconData timerOutlined = Icons.timer_outlined;

  /// ⚠️ Warning outlined
  static const IconData warningOutlined = Icons.warning_outlined;

  /// 💧 Water drop
  static const IconData waterDrop = Icons.water_drop;
}

/// 📦 Icon Groups - For when you need multiple related icons
///
/// **Usage**:
/// ```dart
/// final timerIcons = IconGroups.timer;
/// Icon(timerIcons.active)  // Timer running
/// Icon(timerAppIcons.paused)  // Timer paused
/// ```
class IconGroups {
  IconGroups._();

  /// ⏱️ Timer states
  static const _TimerIcons timer = _TimerIcons();

  /// ✅ Validation states
  static const _ValidationIcons validation = _ValidationIcons();

  /// 📈 Trend directions
  static const _TrendIcons trend = _TrendIcons();

  /// ⭐ Star variants
  static const _StarIcons star = _StarIcons();

  /// 👤 Person variants
  static const _PersonIcons person = _PersonIcons();

  /// 📊 Chart types
  static const _ChartIcons chart = _ChartIcons();
}

class _TimerIcons {
  const _TimerIcons();

  /// ⏱️ Timer active
  IconData get active => Icons.timer;

  /// ⏱️ Timer outlined (deprecated - use active instead)
  IconData get outlined => Icons.timer;

  /// ⏸️ Timer paused/disabled
  IconData get paused => Icons.timer_off;
}

class _ValidationIcons {
  const _ValidationIcons();

  /// ✅ Filled circle
  IconData get filled => Icons.check_circle;

  /// ○ Outlined circle
  IconData get outlined => Icons.check_circle_outline;

  /// ✓ Simple check
  IconData get simple => Icons.check;

  /// ✅✅ All done
  IconData get all => Icons.done_all;
}

class _TrendIcons {
  const _TrendIcons();

  /// 📈 Up
  IconData get up => Icons.trending_up;

  /// 📉 Down
  IconData get down => Icons.trending_down;

  /// → Flat
  IconData get flat => Icons.trending_flat;
}

class _StarIcons {
  const _StarIcons();

  /// ⭐ Filled
  IconData get filled => Icons.star;

  /// ☆ Outline
  IconData get outline => Icons.star_border;

  /// ⭐ Half
  IconData get half => Icons.star_half;
}

class _PersonIcons {
  const _PersonIcons();

  /// 👤 Single person
  IconData get single => Icons.person;

  /// 👤 Person outline
  IconData get outline => Icons.person_outline;

  /// 👥 Multiple people
  IconData get multiple => Icons.people;

  /// 👥 People outline
  IconData get multipleOutline => Icons.people_outline;
}

class _ChartIcons {
  const _ChartIcons();

  /// 📊 Bar chart
  IconData get bar => Icons.bar_chart;

  /// 📈 Line chart
  IconData get line => Icons.show_chart;

  /// 🥧 Pie chart
  IconData get pie => Icons.pie_chart;

  /// 📊 Donut chart
  IconData get donut => Icons.donut_large;
}
