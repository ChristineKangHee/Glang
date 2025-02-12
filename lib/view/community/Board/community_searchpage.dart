import 'package:flutter/material.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../components/custom_app_bar.dart';
import '../../components/my_divider.dart';
import 'Component/component_communitypostlist.dart';
import 'community_data.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  List<Post> _searchResults = [];
  String _searchQuery = "";
  bool _isSearchInitiated = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Initialize TabController with 3 tabs
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
                      icon: Icon(Icons.navigate_before, color: customColors.neutral30),
                      onPressed: () {
                        Navigator.pop(context); //뒷 페이지로 돌아가는 기능. 상황에 맞게 수정.
                      },
                    ),
                    Expanded(
                      child: TextField(
                        style: body_medium(context).copyWith(color: customColors.neutral30),
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '검색어를 입력해주세요',
                          hintStyle: body_medium(context).copyWith(color: customColors.neutral60),
                          border: UnderlineInputBorder(borderSide: BorderSide(
                            color: customColors.primary ?? Colors.purple,
                            width: 2,
                          ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: customColors.neutral60 ?? Colors.grey,
                              width: 2,
                            ),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.cancel_rounded, color: customColors.neutral60),
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
                          _performSearch(query); // Trigger search when the user submits the query
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
            // 검색 기록 표시 조건 추가
            if (!_isSearchInitiated && _searchHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("검색 기록", style: body_small(context).copyWith(color: customColors.neutral80)),
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
            // Show TabBar only when search is initiated
            if (_isSearchInitiated)
              TabBar(
                labelStyle: body_small_semi(context),
                indicatorColor: customColors.primary,
                dividerColor: customColors.neutral80,
                controller: _tabController,
                tabs: const [
                  Tab(text: '전체'),
                  Tab(text: '코스'),
                  Tab(text: '주제'),
                ],
              ),
            // 검색 결과 표시 조건
            Expanded(
              child: _isSearchInitiated
                  ? TabBarView(
                controller: _tabController,
                children: [
                  _buildFilteredPostList(_searchResults, context, customColors), // 전체
                  _buildFilteredPostList(
                      _searchResults.where((post) => post.category == '미션 글').toList(),
                      context,
                      customColors), // 코스
                  _buildFilteredPostList(
                      _searchResults.where((post) => post.category == '자유글' || post.category == '에세이').toList(),
                      context,
                      customColors), // 주제
                ],
              )
                  : Center(
                child: _searchHistory.isEmpty
                    ? Text("최근 검색 기록이 없습니다.", style: body_medium(context).copyWith(color: customColors.neutral60))
                    : SizedBox.shrink(), // 검색 기록이 있으면 아무것도 안 보이게 처리
              ),
            ),
          ],
        ),
      ),
    );
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
        _searchResults = posts
            .where((post) =>
        post.title.contains(finalQuery) ||
            post.content.contains(finalQuery) ||
            post.authorName.contains(finalQuery))
            .toList();
      });

      setState(() {
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
      _isSearchInitiated = false; // Reset to show history again
    });
  }

  Widget _buildRecentSearches() {
    return _searchHistory.isEmpty
        ? Center(
      child: Text("검색어를 입력해주세요.", style: TextStyle(color: Colors.grey)),
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


  Widget _buildFilteredPostList(List<Post> posts, BuildContext context, CustomColors customColors) {
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

}
