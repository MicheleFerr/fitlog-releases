// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

/// 🎨 Centralized icon constants for GymBro app
///
/// **Usage**:
/// ```dart
/// Icon(AppIcons.workout)
/// Icon(AppIcons.timer)
/// Icon(AppIcons.complete)
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

  /// 🧘 Flexibility/Yoga
  static const IconData flexibility = Icons.self_improvement;

  /// ♿ Accessibility/Mobility
  static const IconData accessibility = Icons.accessibility_new;

  /// ⚖️ Weight tracking
  static const IconData weight = Icons.monitor_weight;

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
  static const IconData forward = Icons.arrow_forward;

  /// → Forward iOS style
  static const IconData forwardIos = Icons.arrow_forward_ios;

  /// ▼ Expand more
  static const IconData expandMore = Icons.expand_more;

  /// ▲ Expand less
  static const IconData expandLess = Icons.expand_less;

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
  static const IconData info = Icons.info_outline;

  /// ⚠️ Error
  static const IconData error = Icons.error_outline;

  /// ⚠️ Warning
  static const IconData warning = Icons.warning;

  /// ❓ Help
  static const IconData help = Icons.help_outline;

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
  static const IconData addCircle = Icons.add_circle_outline;

  /// 🗑️ Delete
  static const IconData delete = Icons.delete;

  /// 🗑️ Delete outline
  static const IconData deleteOutline = Icons.delete_outline;

  /// 🔄 Refresh
  static const IconData refresh = Icons.refresh;

  /// 💾 Save
  static const IconData save = Icons.save;

  /// 📋 Copy
  static const IconData copy = Icons.content_copy;

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
  static const IconData filter = Icons.filter_list;

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
  static const IconData upload = Icons.cloud_upload;

  /// 📷 Camera
  static const IconData camera = Icons.camera_alt;

  /// 🖼️ Image
  static const IconData image = Icons.image;

  /// 📄 Document
  static const IconData document = Icons.description;

  /// 🔗 Link
  static const IconData link = Icons.link;

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
  static const IconData errorOutlineRounded = Icons.error_outline_rounded;

  // calendar_today variants (total: 41 usages)
  static const IconData calendarTodayOutlined = Icons.calendar_today_outlined;

  // history variants (total: 37 usages)
  static const IconData historyOutlined = Icons.history_outlined;
  static const IconData historyRounded = Icons.history_rounded;

  // check variants (total: 36 usages)
  static const IconData checkRounded = Icons.check_rounded;

  // analytics variants (total: 36 usages)
  static const IconData analyticsRounded = Icons.analytics_rounded;

  // emoji_events variants (total: 35 usages)
  static const IconData emojiEventsOutlined = Icons.emoji_events_outlined;

  // play_arrow variants (total: 34 usages)
  static const IconData playArrowRounded = Icons.play_arrow_rounded;

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
  static const IconData infoOutlined = Icons.info_outlined;

  // settings variants (total: 16 usages)
  static const IconData settingsRounded = Icons.settings_rounded;

  // rocket_launch variants (total: 15 usages)
  static const IconData rocketLaunchRounded = Icons.rocket_launch_rounded;

  // calendar_month variants (total: 14 usages)
  static const IconData calendarMonthOutlined = Icons.calendar_month_outlined;
  static const IconData calendarMonthRounded = Icons.calendar_month_rounded;

  // insights variants (total: 13 usages)
  static const IconData insightsRounded = Icons.insights_rounded;

  // whatshot variants (total: 13 usages)
  static const IconData whatshotOutlined = Icons.whatshot_outlined;

  // cancel variants (total: 13 usages)
  static const IconData cancelOutlined = Icons.cancel_outlined;
  static const IconData cancelRounded = Icons.cancel_rounded;

  // arrow_forward variants (total: 12 usages)
  static const IconData arrowForwardRounded = Icons.arrow_forward_rounded;

  // pause variants (total: 11 usages)
  static const IconData pauseRounded = Icons.pause_rounded;

  // verified variants (total: 10 usages)
  static const IconData verifiedOutlined = Icons.verified_outlined;
}

/// 📦 Icon Groups - For when you need multiple related icons
///
/// **Usage**:
/// ```dart
/// final timerIcons = IconGroups.timer;
/// Icon(timerIcons.active)  // Timer running
/// Icon(timerIcons.paused)  // Timer paused
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
