/// File: community_searchpage_firebase.dart
/// Purpose: 검색 페이지 위젯 클래스
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희

import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../../components/my_divider.dart';
import 'CM_2depth_boardMain_firebase.dart';
import 'community_data_firebase.dart';
import 'community_service.dart';
import 'component_community_post_firebase.dart';

// 검색 페이지 위젯 클래스
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  // 검색어 입력을 위한 텍스트 컨트롤러
  TextEditingController _searchController = TextEditingController();
  // 최근 검색 기록을 저장할 리스트
  List<String> _searchHistory = [];
  // 검색 결과를 저장할 리스트
  List<Post> _searchResults = [];
  // 전체 게시글 리스트
  List<Post> _allPosts = [];
  // 현재 검색어
  String _searchQuery = "";
  // 검색이 시작되었는지 여부
  bool _isSearchInitiated = false;
  // 탭 컨트롤러
  late TabController _tabController;
  // 커뮤니티 서비스 인스턴스
  final CommunityService _communityService = CommunityService();
  // 게시글 스트림 구독
  StreamSubscription<List<Post>>? _postSubscription;

  // 페이지 초기화 시 호출
  @override
  void initState() {
    super.initState();
    // 탭 컨트롤러 초기화
    _tabController = TabController(length: 3, vsync: this);
    // Firestore에서 전체 게시글 구독 (검색에 사용)
    _postSubscription = _communityService.getPosts().listen((posts) {
      setState(() {
        _allPosts = posts;
      });
    });
  }

  // 페이지 종료 시 호출
  @override
  void dispose() {
    _searchController.dispose(); // 텍스트 컨트롤러 해제
    _tabController.dispose(); // 탭 컨트롤러 해제
    _postSubscription?.cancel(); // 게시글 스트림 구독 해제
    super.dispose();
  }

  // 검색을 수행하는 메서드
  void _performSearch([String query = '']) {
    String finalQuery = query.isNotEmpty ? query : _searchQuery;

    if (finalQuery.isNotEmpty) {
      // 검색어가 검색 기록에 없다면 추가
      if (!_searchHistory.contains(finalQuery)) {
        setState(() {
          _searchHistory.insert(0, finalQuery);
        });
      }

      setState(() {
        // 게시글 제목, 내용, 닉네임에서 검색어를 포함하는 게시글 찾기
        _searchResults = _allPosts
            .where((post) =>
        post.title.contains(finalQuery) ||
            post.content.contains(finalQuery) ||
            post.nickname.contains(finalQuery))
            .toList();
        _isSearchInitiated = true; // 검색이 시작되었음을 표시
      });
    } else {
      setState(() {
        _searchResults.clear(); // 검색어가 없으면 결과를 초기화
      });
    }
  }

  // 검색어를 지우는 메서드
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = "";
      _searchResults.clear();
      _isSearchInitiated = false;
    });
  }

  // 최근 검색 기록을 보여주는 위젯
  Widget _buildRecentSearches() {
    return _searchHistory.isEmpty
        ? Center(
      child:
          Text('search.enter_keyword'.tr(), // '검색어를 입력해주세요'
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

  // 필터링된 게시글 리스트를 보여주는 위젯
  Widget _buildFilteredPostList(
      List<Post> posts, BuildContext context, CustomColors customColors) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          "search.no_results".tr(),
          style: body_medium(context).copyWith(color: customColors.neutral60),
        ),
      );
    }

    return ListView.builder(
      itemCount: posts.length * 2 - 1, // 각 아이템 사이에 Divider 추가
      itemBuilder: (context, index) {
        if (index.isOdd) {
          return BigDivider();
        } else {
          var post = posts[index ~/ 2];
          return PostItemContainer(
            post: post,
            customColors: customColors,
            parentContext: context,
          );
        }
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
            // 검색어 입력 필드
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
                        Navigator.pop(context); // 뒤로 가기
                      },
                    ),
                    Expanded(
                      child: TextField(
                        style: body_medium(context)
                            .copyWith(color: customColors.neutral30),
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'search.enter_keyword'.tr(), // '검색어를 입력해주세요'
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
                            _searchQuery = query; // 실시간 검색어 업데이트
                          });
                        },
                        onSubmitted: (query) {
                          _performSearch(query); // 검색어 제출 시 검색 수행
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _performSearch, // 검색 버튼 클릭 시 검색 수행
                    ),
                  ],
                ),
              ),
            ),
            // 검색 기록이 있을 때만 표시
            if (!_isSearchInitiated && _searchHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("search.history_title".tr(), //'검색 기록'
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
                            _performSearch(_searchHistory[index]); // 검색 기록 클릭 시 검색 수행
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            // 검색이 시작되었을 때 탭바 및 결과 표시
            if (_isSearchInitiated)
              TabBar(
                labelStyle: body_small_semi(context),
                indicatorColor: customColors.primary,
                dividerColor: customColors.neutral80,
                controller: _tabController,
                tabs: [
                  Tab(text: 'community.all'.tr()),
                  Tab(text: 'community.essay'.tr()),
                  Tab(text: 'community.free'.tr()),
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
                    ? Text("search.no_history".tr(),
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
