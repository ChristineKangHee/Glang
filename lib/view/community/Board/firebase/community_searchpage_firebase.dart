import 'dart:async';
import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'CM_2depth_boardMain_firebase.dart';
import 'community_data_firebase.dart';
import 'community_service.dart';
import 'component_community_post_firebase.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  List<Post> _searchResults = [];
  List<Post> _allPosts = [];
  String _searchQuery = "";
  bool _isSearchInitiated = false;
  late TabController _tabController;
  final CommunityService _communityService = CommunityService();
  StreamSubscription<List<Post>>? _postSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Firestore에서 전체 게시글 구독 (검색에 사용)
    _postSubscription = _communityService.getPosts().listen((posts) {
      setState(() {
        _allPosts = posts;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _postSubscription?.cancel();
    super.dispose();
  }

  void _performSearch([String query = '']) {
    String finalQuery = query.isNotEmpty ? query : _searchQuery;

    if (finalQuery.isNotEmpty) {
      if (!_searchHistory.contains(finalQuery)) {
        setState(() {
          _searchHistory.insert(0, finalQuery);
        });
      }

      setState(() {
        _searchResults = _allPosts
            .where((post) =>
        post.title.contains(finalQuery) ||
            post.content.contains(finalQuery) ||
            post.authorName.contains(finalQuery))
            .toList();
        _isSearchInitiated = true;
      });
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = "";
      _searchResults.clear();
      _isSearchInitiated = false;
    });
  }

  Widget _buildRecentSearches() {
    return _searchHistory.isEmpty
        ? Center(
      child: Text("검색어를 입력해주세요.",
          style: TextStyle(color: Colors.grey)),
    )
        : ListView.builder(
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_searchHistory[index]),
          onTap: () {
            _searchController.text = _searchHistory[index];
            _performSearch(_searchHistory[index]);
          },
        );
      },
    );
  }

  Widget _buildFilteredPostList(
      List<Post> posts, BuildContext context, CustomColors customColors) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          "검색 결과가 없습니다.",
          style: body_medium(context).copyWith(color: customColors.neutral60),
        ),
      );
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        var post = posts[index];
        return PostItemContainer(
          post: post,
          customColors: customColors,
          context: context,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: customColors.neutral100,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.navigate_before,
                          color: customColors.neutral30),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: TextField(
                        style: body_medium(context)
                            .copyWith(color: customColors.neutral30),
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '검색어를 입력해주세요',
                          hintStyle: body_medium(context)
                              .copyWith(color: customColors.neutral60),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: customColors.primary ?? Colors.purple,
                                width: 2,
                              )),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: customColors.neutral60 ?? Colors.grey,
                              width: 2,
                            ),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.cancel_rounded,
                                color: customColors.neutral60),
                            onPressed: _clearSearch,
                          )
                              : null,
                        ),
                        onChanged: (query) {
                          setState(() {
                            _searchQuery = query;
                          });
                        },
                        onSubmitted: (query) {
                          _performSearch(query);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                  ],
                ),
              ),
            ),
            if (!_isSearchInitiated && _searchHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("검색 기록",
                        style: body_small(context)
                            .copyWith(color: customColors.neutral80)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_searchHistory[index]),
                          onTap: () {
                            _searchController.text = _searchHistory[index];
                            _performSearch(_searchHistory[index]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (_isSearchInitiated)
              TabBar(
                labelStyle: body_small_semi(context),
                indicatorColor: customColors.primary,
                dividerColor: customColors.neutral80,
                controller: _tabController,
                tabs: const [
                  Tab(text: '전체'),
                  Tab(text: '에세이'),
                  Tab(text: '자유글'),
                ],
              ),
            Expanded(
              child: _isSearchInitiated
                  ? TabBarView(
                controller: _tabController,
                children: [
                  _buildFilteredPostList(
                      _searchResults, context, customColors),
                  _buildFilteredPostList(
                      _searchResults
                          .where((post) => post.category == '에세이')
                          .toList(),
                      context,
                      customColors),
                  _buildFilteredPostList(
                      _searchResults
                          .where((post) => post.category == '자유글')
                          .toList(),
                      context,
                      customColors),
                ],
              )
                  : Center(
                child: _searchHistory.isEmpty
                    ? Text("최근 검색 기록이 없습니다.",
                    style: body_medium(context)
                        .copyWith(color: customColors.neutral60))
                    : SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
