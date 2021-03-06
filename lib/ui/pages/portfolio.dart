import 'dart:math';

import 'package:expandable_card/expandable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_test/ui/components/icon_bar.dart';
import 'package:flutter_web_test/ui/components/picture_manager.dart';
import 'package:flutter_web_test/utils/functions.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:transparent_image/transparent_image.dart';

import 'home.dart';


class PortfolioPage extends StatefulWidget {

  PortfolioPage();

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  ScrollController _scrollController = ScrollController();

  AnimationController _animController;
  int _index = 0, _subindex = 0;
  double _screenSize = 0;

  PictureManager manager;

  @override
  void initState() {
    _animController = AnimationController(vsync: this);
    super.initState();
    _initializeManager();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeManager() async {
    manager = await PictureManager.fromUrl(
      jsonUrl: "https://raw.githubusercontent.com/howardt12345/website/master/portfolio.json",
      url: "https://firebasestorage.googleapis.com/v0/b/portfolio-49b69.appspot.com/o/",
      token: "810d1310-0533-4e13-bc33-6fc77ac56ef1",
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _screenSize = screenWidth(context: context);
      _scaffoldKey = new GlobalKey();
    });
    return FutureBuilder(
      future: _initializeManager(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if(snapshot.connectionState == ConnectionState.done){
          return OrientationBuilder(
            builder: (context, orientation) => Container(
              height: screenHeight(context: context),
              width: screenWidth(context: context),
              child: (/*orientation == Orientation.portrait || */_screenSize <= 600)
                  ? _buildVerticalLayout()
                  : _buildHorizontalLayout(),
            ),
          );
        } else {
          return Center(
            child: Text("oop"),
          );
        }
      },
    );
  }

  _buildVerticalLayout() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
          icon: Icon(
            Icons.menu,
            size: 24,
            color: Theme.of(context).textTheme.body2.color,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: _buildIconDrawer(),
      ),
      drawer: Drawer(
        child: _buildFullDrawer(),
      ),
      body: _buildViewer(true)
    );
  }
  _buildHorizontalLayout() {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: _buildFullDrawer(),
          ),
          Expanded(
            flex: 3,
            child: _buildViewer(false),
          ),
        ],
      ),
    );
  }

  _buildViewer(bool portrait) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: portrait ? 0 : 56.0,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: manager.getCategories()[_index],
                        style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: 40,
                        ),
                      ),
                      TextSpan(
                        text: ": ${_subindex == 0 ? "All" : manager.getSubcategoriesFrom(_index)[_subindex]}",
                        style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ]
                  ),
                ),
              ),
            ),
            StaggeredGridView.count(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              crossAxisCount: 12,
              staggeredTiles: _getTiles(),
              children: _getWidgets(),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              padding: const EdgeInsets.all(4.0),
            ),
            buildCopyrightText(),
          ],
        ),
      ),
    );
  }

  _buildIconDrawer() {
    return Container(
      height: 56.0,
      decoration: BoxDecoration(
      ),
      child: GestureDetector(
        child: Align(
          alignment: Alignment.centerLeft,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: manager.getCategories().map((c) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _index = manager.getCategories().indexOf(c);
                    _subindex = 0;
                  });
                },
                icon: Icon(
                  iconMapping[manager.getPicturesAt(c, 'icon')[0].title],
                  color: _index == manager.getCategories().indexOf(c) ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153),
                  size: 24,
                ),
              );
            }).toList(),
          ),
        ),
      )
    );
  }

  _buildFullDrawer() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            width: 1.0,
            color: Theme.of(context).textTheme.title.color
          )
        )
      ),
      child: Center(
        child: AnimatedList(
          key: _listKey,
          shrinkWrap: true,
          initialItemCount: manager.getCategories().length,
          itemBuilder: (context, index, animation) => _buildItem(context, manager.getCategory(index), index, animation),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String item, int index, Animation animation) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _index = index;
          _subindex = 0;
        });
      },
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 8.0),
                      Text(
                        item,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: _index == index ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153)
                        ),
                      ),
                      SizedBox(height: 8.0),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: _index == index ? item.length * 10 : 0,
                        height: 2.0,
                        color: Theme.of(context).textTheme.body2.color,
                        curve: Curves.ease,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  iconMapping[manager.getPicturesAt(manager.getCategory(index), 'icon')[0].title],
                  color: _index == index ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153),
                  size: 24,
                ),
              ),
            ],
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _index == index ? manager.getSubcategoriesFrom(_index).length * 36 : 0,
            curve: Curves.ease,
            child: _index == index ? Column(
              children: manager.getSubcategoriesFrom(index).map((s) {
                if(manager.getSubcategoriesFrom(index).indexOf(s) == 0) {
                  return _buildSubMenu(context, "All", 0);
                } else {
                  return _buildSubMenu(context, s,
                      manager.getSubcategoriesFrom(index).indexOf(s));
                }
              }).toList(),
            ) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenu(BuildContext context, String item, int subindex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _subindex = subindex;
        });
      },
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              item,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.body2.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _subindex == subindex ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153)
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getWidgets() {
    List<Widget> widgets = [];
    if(_subindex == 0) {
      for(var i = 1; i < manager.getPicturesAt(manager.getCategory(_index), 'icon').length; i++) {
        var pic = manager.getPicturesAt(manager.getCategory(_index), 'icon')[i];
        print('${manager.url}'
            '${pic.path.replaceAll('/', '%2F')}%2F'
            '${pic.title.replaceAll(' ', '%20')}?alt=media&token='
            '${manager.token}');
        widgets.add(
            _ImageTile(
              pic: pic,
              url: manager.url,
              token: manager.token,
            )
        );
      }
    } else {
      for(var i = 0; i < manager.getPicturesFrom(_index, _subindex).length; i++) {
        var pic = manager.getPicturesFrom(_index, _subindex)[i];
        print('${manager.url}'
            '${pic.path.replaceAll('/', '%2F')}%2F'
            '${pic.title.replaceAll(' ', '%20')}?alt=media&token='
            '${manager.token}');
        widgets.add(
            _ImageTile(
              pic: pic,
              url: manager.url,
              token: manager.token,
            )
        );
      }
    }
    return widgets;
  }

  List<StaggeredTile> _getTiles() {
    List<StaggeredTile> tiles = [];
    if(_subindex == 0) {
      for(var i = 1; i < manager.getPicturesAt(manager.getCategory(_index), 'icon').length; i++) {
        var pic = manager.getPicturesAt(manager.getCategory(_index), 'icon')[i];
        tiles.add(
            StaggeredTile.count(
                pic.width,
                pic.height
            )
        );
      }
    } else {
      for(var i = 0; i < manager.getPicturesFrom(_index, _subindex).length; i++) {
        var pic = manager.getPicturesFrom(_index, _subindex)[i];
        tiles.add(
            StaggeredTile.count(
                pic.width,
                pic.height
            )
        );
      }
    }
    return tiles;
  }

}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    this.pic,
    this.url,
    this.token,
  });

  final pic, url, token;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      margin: EdgeInsets.all(1.0),
      child: new GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return _DetailScreen(
              pic: pic,
              url: url,
              token: token,
            );
          }));
        },
        child: Stack(
          children: [
            Center(child: CircularProgressIndicator()),
            Center(
              child: Hero(
                tag: '${pic.path}/${pic.title}',
                child: FadeInImage.memoryNetwork(
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                  placeholder: kTransparentImage,
                  image: '$url${pic.path.replaceAll('/', '%2F')}%2F${pic.title.replaceAll(' ', '%20')}?alt=media&token=$token',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailScreen extends StatefulWidget {
  final Picture pic;
  final String url, token;

  _DetailScreen({
    this.pic,
    this.url,
    this.token,
  });

  @override
  __DetailScreenState createState() => __DetailScreenState();
}

class __DetailScreenState extends State<_DetailScreen> {
  double _screenSize = 0;

  @override
  Widget build(BuildContext context) {
    return (MediaQuery.of(context).size.aspectRatio < widget.pic.width/widget.pic.height)
        ? _buildVerticalLayout()
        : _buildHorizontalLayout();
  }

  _buildVerticalLayout() {
    print("vertical");
    return GestureDetector(
      child: ExpandableCardPage(
        page: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 5 / 4,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
                Align(
                  alignment: Alignment.center,
                  child: PhotoView(
                    backgroundDecoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor
                    ),
                    imageProvider: NetworkImage(
                      '${widget.url}${widget.pic.path.replaceAll('/', '%2F')}%2F${widget.pic.title.replaceAll(' ', '%20')}?alt=media&token=${widget.token}',
                    ),
                    maxScale: PhotoViewComputedScale.covered * 2.0,
                    minScale: PhotoViewComputedScale.contained,
                    initialScale: PhotoViewComputedScale.contained,
                    heroTag: '${widget.pic.path}/${widget.pic.title}',
                  ),
                ),
              ],
            ),
          ),
        ),
        expandableCard: ExpandableCard(
          hasHandle: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          minHeight: 56,
          hasShadow: false,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  height: 24,
                  width: 24,
                  child: widget.pic.download.isNotEmpty
                    ? IconBarButton(
                        url: '${widget.url}${widget.pic.path.replaceAll('/', '%2F')}%2F${widget.pic.download.replaceAll(' ', '%20')}?alt=media&token=${widget.token}',
                        iconData: iconMapping['download'],
                      )
                    : null,
                ),
                Expanded(
                  child: Container(
                    child: Icon(
                      Icons.remove,
                      color: Theme.of(context).textTheme.body1.color,
                      size: 24,
                    ),
                  ),
                ),
                Container(
                  height: 24,
                  width: 24,
                  child: widget.pic.buy.isNotEmpty
                  ? IconBarButton(
                    url: widget.pic.buy,
                    iconData: iconMapping['buy'],
                    )
                  : null,
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 24.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: RichText(
                  text: TextSpan(
                    text: widget.pic.description,
                    style: Theme.of(context).textTheme.body1.copyWith(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  _buildHorizontalLayout() {
    print("horizontal");
    return GestureDetector(
      child: Container(
        child: Stack(
          children: [
            Container(
              color: Colors.black,
            ),
            Align(
              alignment: AlignmentDirectional(-0.5, 0),
              child: CircularProgressIndicator(),
            ),
            Align(
              alignment: AlignmentDirectional(-0.5, 0),
              child: Hero(
                tag: '${widget.pic.path}/${widget.pic.title}',
                child: FadeInImage.memoryNetwork(
                  fit: BoxFit.fill,
                  alignment: Alignment.center,
                  placeholder: kTransparentImage,
                  image: '${widget.url}${widget.pic.path.replaceAll('/', '%2F')}%2F${widget.pic.title.replaceAll(' ', '%20')}?alt=media&token=${widget.token}',
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.black.withAlpha(0), Colors.black.withAlpha(155)],
                        tileMode: TileMode.repeated,
                      ),
                    ),
                    width: 84.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/4-84,
                    color: Colors.black.withAlpha(155),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
