import 'package:data_portal_survey/common/theme/app_shapes.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:krishi_hub/common/app/theme.dart';
// import 'package:krishi_hub/common/constant/env.dart';
// import 'package:krishi_hub/common/constant/locale_keys.dart';
// import 'package:krishi_hub/common/cubit/data_state.dart';
// import 'package:krishi_hub/common/hive/hive_storage.dart';
// import 'package:krishi_hub/common/navigation/navigation_service.dart';
// import 'package:krishi_hub/common/utils/size_utils.dart';
// import 'package:krishi_hub/common/widget/app_bar/custom_app_bar.dart';
// import 'package:krishi_hub/common/widget/audio/common_seek_bar.dart';
// import 'package:krishi_hub/common/widget/loading_overlay.dart';
// import 'package:krishi_hub/feature/notification/cubit/get_audio_ai_cubit.dart';
// import 'package:rxdart/rxdart.dart';

// class AudioNotificationWidget extends StatefulWidget {
//   const AudioNotificationWidget({super.key});

//   @override
//   State<AudioNotificationWidget> createState() =>
//       _AudioNotificationWidgetState();
// }

// class _AudioNotificationWidgetState extends State<AudioNotificationWidget>
//     with WidgetsBindingObserver {
//   final _player = AudioPlayer();
//   bool _isLoading = false;
//   String? _audioUrl;
//   bool _hasError = false;
//   String _errorMessage = '';

//   Map<String, String> get header => {
//         'content-type': 'audio/mpeg',
//         'accept': 'audio/mpeg',
//         'origin': '*',
//         "x-api-key":
//             RepositoryProvider.of<Env>(NavigationService.context).webSecreteKey
//       };

//   @override
//   void initState() {
//     super.initState();
//     ambiguate(WidgetsBinding.instance)!.addObserver(this);
//     _loadUserPreferencesAndFetchAudio();
//   }

//   Future<void> _loadUserPreferencesAndFetchAudio() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     try {
//       // Load user preferences from Hive
//       final cropBox = await HiveStorage().getBox(HiveStorage().cropList);
//       final livestockBox = await HiveStorage().getBox(HiveStorage().liveStock);
//       final areaBox = await HiveStorage().getBox(HiveStorage().area);

//       final crops = cropBox.values.cast<String>().toList();
//       final livestock = livestockBox.values.cast<String>().toList();
//       final location = areaBox.get('location') as String?;

//       if (location == null || crops.isEmpty || livestock.isEmpty) {
//         setState(() {
//           _isLoading = false;
//           _hasError = true;
//           _errorMessage = LocaleKeys.selectAtLeastOne.tr();
//         });
//         return;
//       }

//       await context.read<GetAudioAiCubit>().getAudioAi(
//             location: location,
//             crops: crops,
//             livestock: livestock,
//           );
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _hasError = true;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   Future<void> _initAudioPlayer(String url, {bool isLocalFile = false}) async {
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.speech());

//     _player.playbackEventStream.listen((event) {},
//         onError: (Object e, StackTrace stackTrace) {
//       debugPrint('Audio stream error: $e');
//     });

//     try {
//       // Check if URL is a local file path or remote URL
//       final isFilePath = !url.startsWith('http');

//       if (isFilePath) {
//         // Play from local file
//         await _player.setAudioSource(
//           AudioSource.file(url),
//         );
//       } else {
//         // Play from URL
//         await _player.setAudioSource(
//           AudioSource.uri(
//             Uri.parse(url),
//             headers: header,
//           ),
//         );
//       }

//       setState(() {
//         _audioUrl = url;
//       });
//       // Auto-play the audio
//       await _player.play();
//     } on PlayerException catch (e) {
//       debugPrint("Error loading audio: $e");
//       setState(() {
//         _hasError = true;
//         _errorMessage = LocaleKeys.failedToLoadAudio.tr();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     ambiguate(WidgetsBinding.instance)!.removeObserver(this);
//     _player.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       _player.stop();
//     }
//   }

//   Stream<PositionData> get _positionDataStream =>
//       Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//           _player.positionStream,
//           _player.bufferedPositionStream,
//           _player.durationStream,
//           (position, bufferedPosition, duration) => PositionData(
//               position, bufferedPosition, duration ?? Duration.zero));

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textTheme = theme.textTheme;

//     return BlocListener<GetAudioAiCubit, CommonState>(
//       listener: (context, state) {
//         if (state is CommonLoading) {
//           setState(() {
//             _isLoading = true;
//             _hasError = false;
//           });
//         } else if (state is CommonStateSuccess<String>) {
//           setState(() {
//             _isLoading = false;
//           });
//           if (state.data.isNotEmpty) {
//             _initAudioPlayer(state.data, isLocalFile: false);
//           }
//         } else if (state is CommonError) {
//           setState(() {
//             _isLoading = false;
//             _hasError = true;
//             _errorMessage = state.message;
//           });
//         }
//       },
//       child: LoadingOverlay(
//         isLoading: _isLoading,
//         child: Scaffold(
//           // backgroundColor: CustomTheme.lightGray.withOpacity(0.3),
//           appBar: CustomAppBar(
//               // title: LocaleKeys.aiAdvisory.tr(),
//               ),
//           body: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Header Section
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(20.wp),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         theme.primaryColor,
//                         theme.primaryColor.withOpacity(0.8),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(20.wp),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.newspaper,
//                           size: 60,
//                           color: Colors.white,
//                         ),
//                       ),
//                       SizedBox(height: 16.hp),
//                       Text(
//                         LocaleKeys.aiPoweredFarmingAdvisory.tr(),
//                         style: textTheme.headlineMedium!.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 8.hp),
//                       Text(
//                         LocaleKeys.personalizedGuidance.tr(),
//                         style: textTheme.bodyMedium!.copyWith(
//                           color: Colors.white.withOpacity(0.9),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Content Section
//                 Padding(
//                   padding: EdgeInsets.all(16.wp),
//                   child: Column(
//                     children: [
//                       // Audio Player Card
//                       if (_audioUrl != null && !_hasError)
//                         Container(
//                           padding: EdgeInsets.all(20.wp),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: AppShapes.radiusLg,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.08),
//                                 blurRadius: 12,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             children: [
//                               // Waveform Visual
//                               Container(
//                                 height: 100.hp,
//                                 decoration: BoxDecoration(
//                                   color: theme.primaryColor.withOpacity(0.05),
//                                   borderRadius: AppShapes.radiusMd,
//                                 ),
//                                 child: Center(
//                                   child: Icon(
//                                     Icons.graphic_eq,
//                                     size: 60,
//                                     color: theme.primaryColor.withOpacity(0.3),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 24.hp),

//                               // Audio Controls
//                               StreamBuilder<PositionData>(
//                                 stream: _positionDataStream,
//                                 builder: (context, snapshot) {
//                                   final positionData = snapshot.data;
//                                   return Column(
//                                     children: [
//                                       SeekBar(
//                                         duration: positionData?.duration ??
//                                             Duration.zero,
//                                         position: positionData?.position ??
//                                             Duration.zero,
//                                         bufferedPosition:
//                                             positionData?.bufferedPosition ??
//                                                 Duration.zero,
//                                         onChangeEnd: _player.seek,
//                                       ),
//                                       SizedBox(height: 16.hp),
//                                       _buildControlButtons(),
//                                     ],
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),

//                       // Error State
//                       if (_hasError && !_isLoading)
//                         Container(
//                           padding: EdgeInsets.all(20.wp),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: AppShapes.radiusLg,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.08),
//                                 blurRadius: 12,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             children: [
//                               Icon(
//                                 Icons.error_outline,
//                                 size: 60,
//                                 color: Colors.red.shade400,
//                               ),
//                               SizedBox(height: 16.hp),
//                               Text(
//                                 LocaleKeys.unableToLoadAdvisory.tr(),
//                                 style: textTheme.titleLarge!.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 8.hp),
//                               Text(
//                                 _errorMessage,
//                                 style: textTheme.bodyMedium!.copyWith(
//                                   color: CustomTheme.grey,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                               SizedBox(height: 16.hp),
//                               ElevatedButton.icon(
//                                 onPressed: _loadUserPreferencesAndFetchAudio,
//                                 icon: const Icon(Icons.refresh),
//                                 label: Text(LocaleKeys.retry.tr()),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: theme.primaryColor,
//                                   foregroundColor: Colors.white,
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 24.wp,
//                                     vertical: 12.hp,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: AppShapes.radiusMd,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                       SizedBox(height: 20.hp),

//                       // Info Cards
//                       // _buildInfoCard(
//                       //   icon: Icons.smart_toy_outlined,
//                       //   title: LocaleKeys.aiGeneratedContent.tr(),
//                       //   description: LocaleKeys.aiGeneratedContentDesc.tr(),
//                       //   color: Colors.blue,
//                       // ),
//                       // SizedBox(height: 12.hp),
//                       // _buildInfoCard(
//                       //   icon: Icons.trending_up,
//                       //   title: LocaleKeys.dataDrivenInsights.tr(),
//                       //   description: LocaleKeys.dataDrivenInsightsDesc.tr(),
//                       //   color: Colors.green,
//                       // ),
//                       // SizedBox(height: 12.hp),
//                       // _buildInfoCard(
//                       //   icon: Icons.language,
//                       //   title: LocaleKeys.localLanguageSupport.tr(),
//                       //   description: LocaleKeys.localLanguageSupportDesc.tr(),
//                       //   color: Colors.orange,
//                       // ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildControlButtons() {
//     final theme = Theme.of(context);
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Previous 10s
//         IconButton(
//           icon: const Icon(Icons.replay_10),
//           iconSize: 40,
//           color: theme.primaryColor,
//           onPressed: () {
//             final newPosition = _player.position - const Duration(seconds: 10);
//             _player.seek(
//                 newPosition >= Duration.zero ? newPosition : Duration.zero);
//           },
//         ),
//         SizedBox(width: 20.wp),

//         // Play/Pause
//         StreamBuilder<PlayerState>(
//           stream: _player.playerStateStream,
//           builder: (context, snapshot) {
//             final playerState = snapshot.data;
//             final processingState = playerState?.processingState;
//             final playing = playerState?.playing;

//             if (processingState == ProcessingState.loading ||
//                 processingState == ProcessingState.buffering) {
//               return Container(
//                 width: 64,
//                 height: 64,
//                 margin: EdgeInsets.all(8.wp),
//                 child: CircularProgressIndicator(
//                   color: theme.primaryColor,
//                 ),
//               );
//             } else if (playing != true) {
//               return IconButton(
//                 icon: const Icon(Icons.play_circle_filled),
//                 iconSize: 80,
//                 color: theme.primaryColor,
//                 onPressed: _player.play,
//               );
//             } else if (processingState != ProcessingState.completed) {
//               return IconButton(
//                 icon: const Icon(Icons.pause_circle_filled),
//                 iconSize: 80,
//                 color: theme.primaryColor,
//                 onPressed: _player.pause,
//               );
//             } else {
//               return IconButton(
//                 icon: const Icon(Icons.replay_circle_filled),
//                 iconSize: 80,
//                 color: theme.primaryColor,
//                 onPressed: () => _player.seek(Duration.zero),
//               );
//             }
//           },
//         ),
//         SizedBox(width: 20.wp),

//         // Forward 10s
//         IconButton(
//           icon: const Icon(Icons.forward_10),
//           iconSize: 40,
//           color: theme.primaryColor,
//           onPressed: () {
//             final newPosition = _player.position + const Duration(seconds: 10);
//             final duration = _player.duration ?? Duration.zero;
//             _player.seek(newPosition <= duration ? newPosition : duration);
//           },
//         ),
//       ],
//     );
//   }
// }

// T? ambiguate<T>(T? value) => value;
