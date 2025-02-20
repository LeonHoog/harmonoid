/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2021, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:harmonoid/core/hotkeys.dart';
import 'package:harmonoid/utils/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/core/intent.dart';
import 'package:harmonoid/interface/collection/collectionalbum.dart';
import 'package:harmonoid/interface/collection/collectiontrack.dart';
import 'package:harmonoid/interface/collection/collectionartist.dart';
import 'package:harmonoid/interface/collection/collectionplaylist.dart';
import 'package:harmonoid/interface/youtube/youtubemusic.dart';
import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/interface/changenotifiers.dart';
import 'package:harmonoid/interface/collection/collectionsearch.dart';
import 'package:harmonoid/interface/settings/settings.dart';
import 'package:harmonoid/utils/widgets.dart';

class CollectionMusic extends StatefulWidget {
  const CollectionMusic({Key? key}) : super(key: key);
  CollectionMusicState createState() => CollectionMusicState();
}

class CollectionMusicState extends State<CollectionMusic>
    with AutomaticKeepAliveClientMixin {
  int index = 0;
  final FocusNode node = FocusNode();
  final ValueNotifier<String> query = ValueNotifier<String>('');
  String string = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    intent.play();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: index != 5 ? RefreshCollectionButton() : null,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
              top: kDesktopTitleBarHeight + kDesktopAppBarHeight,
            ),
            child: Consumer<CollectionRefreshController>(
              builder: (context, refresh, __) => Stack(
                alignment: Alignment.bottomLeft,
                children: <Widget>[
                  PageTransitionSwitcher(
                    child: [
                      CollectionAlbumTab(),
                      CollectionTrackTab(),
                      CollectionArtistTab(),
                      CollectionPlaylistTab(),
                      CollectionSearch(query: query),
                      YouTubeMusic(),
                    ][this.index],
                    transitionBuilder: (child, animation, secondaryAnimation) =>
                        SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.vertical,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      child: child,
                    ),
                  ),
                  if (refresh.progress != refresh.total)
                    Card(
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.only(
                        top: 16.0,
                        bottom: 16.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      elevation: 4.0,
                      child: Container(
                        color: Theme.of(context).cardColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: refresh.progress / refresh.total,
                              valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).primaryColor,
                              ),
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.4),
                            ),
                            Container(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16.0,
                                  ),
                                  Text(
                                    '${refresh.progress}/${refresh.total}',
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                  ),
                                  SizedBox(
                                    width: 16.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                      language.COLLECTION_INDEXING_LABEL,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              DesktopTitleBar(),
              ClipRect(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: kDesktopAppBarHeight + 8.0,
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Material(
                    elevation: 4.0,
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 44.0,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(8.0),
                                  onTap: () =>
                                      this.setState(() => this.index = 0),
                                  child: Container(
                                    height: 40.0,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      language.ALBUM.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: this.index == 0
                                            ? FontWeight.w600
                                            : FontWeight.w300,
                                        color: (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(
                                                this.index == 0 ? 1.0 : 0.67),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8.0),
                                  onTap: () =>
                                      this.setState(() => this.index = 1),
                                  child: Container(
                                    height: 40.0,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      language.TRACK.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: this.index == 1
                                            ? FontWeight.w600
                                            : FontWeight.w300,
                                        color: (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(
                                                this.index == 1 ? 1.0 : 0.67),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8.0),
                                  onTap: () =>
                                      this.setState(() => this.index = 2),
                                  child: Container(
                                    height: 40.0,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      language.ARTIST.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: this.index == 2
                                            ? FontWeight.w600
                                            : FontWeight.w300,
                                        color: (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(
                                                this.index == 2 ? 1.0 : 0.67),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8.0),
                                  onTap: () =>
                                      this.setState(() => this.index = 3),
                                  child: Container(
                                    height: 40.0,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      language.PLAYLISTS.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: this.index == 3
                                            ? FontWeight.w600
                                            : FontWeight.w300,
                                        color: (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(
                                                this.index == 3 ? 1.0 : 0.67),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8.0),
                                  onTap: () =>
                                      this.setState(() => this.index = 5),
                                  child: Container(
                                    height: 40.0,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      'YouTube'.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: this.index == 5
                                            ? FontWeight.w600
                                            : FontWeight.w300,
                                        color: (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(
                                                this.index == 5 ? 1.0 : 0.67),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 42.0,
                          width: 280.0,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
                          padding: EdgeInsets.only(top: 2.0),
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                HotKeys.disableSpaceHotKey();
                              } else {
                                HotKeys.enableSpaceHotKey();
                              }
                            },
                            child: TextField(
                              focusNode: this.node,
                              cursorWidth: 1.0,
                              onChanged: (value) {
                                string = value;
                              },
                              onSubmitted: (value) {
                                query.value = value;
                                if (string.isNotEmpty)
                                  this.setState(() {
                                    this.index = 4;
                                  });
                                this.node.requestFocus();
                              },
                              cursorColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: Theme.of(context).textTheme.headline4,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  onPressed: () {
                                    query.value = string;
                                    if (string.isNotEmpty)
                                      this.setState(() {
                                        this.index = 4;
                                      });
                                    this.node.requestFocus();
                                  },
                                  icon: Transform.rotate(
                                    angle: pi / 2,
                                    child: Icon(
                                      Icons.search,
                                      size: 20.0,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                ),
                                contentPadding:
                                    EdgeInsets.only(left: 10.0, bottom: 14.0),
                                hintText: language.COLLECTION_SEARCH_WELCOME,
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black.withOpacity(0.6)
                                          : Colors.white60,
                                    ),
                                filled: true,
                                fillColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Color(0xFF202020),
                                hoverColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Color(0xFF202020),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.32),
                                    width: 0.6,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.32),
                                    width: 0.6,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.32),
                                    width: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 24.0,
                        ),
                        ContextMenuButton<CollectionSort>(
                          offset: Offset.fromDirection(pi / 2, 64.0),
                          icon: Icon(
                            Icons.sort,
                            size: 20.0,
                          ),
                          elevation: 4.0,
                          onSelected: (value) async {
                            Provider.of<Collection>(context, listen: false)
                                .sort(type: value);
                            await configuration.save(
                              collectionSortType: value,
                            );
                          },
                          itemBuilder: (context) => [
                            CheckedPopupMenuItem(
                              padding: EdgeInsets.zero,
                              checked: collection.collectionSortType ==
                                  CollectionSort.aToZ,
                              value: CollectionSort.aToZ,
                              child: Text(
                                language.A_TO_Z,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                            CheckedPopupMenuItem(
                              padding: EdgeInsets.zero,
                              checked: collection.collectionSortType ==
                                  CollectionSort.dateAdded,
                              value: CollectionSort.dateAdded,
                              child: Text(
                                language.DATE_ADDED,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                            CheckedPopupMenuItem(
                              padding: EdgeInsets.zero,
                              checked: collection.collectionSortType ==
                                  CollectionSort.year,
                              value: CollectionSort.year,
                              child: Text(
                                language.YEAR,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      FadeThroughTransition(
                                    fillColor: Colors.transparent,
                                    animation: animation,
                                    secondaryAnimation: secondaryAnimation,
                                    child: Settings(),
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              child: Icon(
                                Icons.settings,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
