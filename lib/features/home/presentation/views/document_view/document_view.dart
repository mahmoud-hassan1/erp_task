import 'package:erp_task/features/home/domain/entities/document.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentView extends StatefulWidget {
  const DocumentView({super.key, required this.document});
  final Document document;

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  late PdfViewerController _pdfViewerController;
  late TextEditingController _searchController;
  PdfTextSearchResult _searchResult = PdfTextSearchResult();
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    _searchController = TextEditingController();
    _searchResult = PdfTextSearchResult();

    _searchResult.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void _onSearchResultChanged() {
    setState(() {});
  }

  @override
  @override
  void dispose() {
    _searchResult.removeListener(_onSearchResultChanged);
    _pdfViewerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search'),
                  content: TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(hintText: 'Enter text'),
                    onSubmitted: (value) async {
                      _searchResult.removeListener(
                          _onSearchResultChanged); // remove old listener if needed
                      _searchResult = _pdfViewerController.searchText(value);
                      _searchResult.addListener(
                          _onSearchResultChanged); // add listener to the new instance

                      setState(() {});
                      if (_searchResult.hasResult) {
                        _searchResult.nextInstance();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        _searchResult.removeListener(_onSearchResultChanged);
                        _searchResult = _pdfViewerController
                            .searchText(_searchController.text);
                        _searchResult.addListener(_onSearchResultChanged);

                        setState(() {});
                        if (_searchResult.hasResult) {
                          _searchResult.nextInstance();
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('Search'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.document.docLink,
            controller: _pdfViewerController,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            onDocumentLoaded: (details) {
              setState(() {
                _totalPages = _pdfViewerController.pageCount;
              });
            },
            onPageChanged: (details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
          ),
          if (_searchResult.hasResult)
            Positioned(
              top: 16,
              right: 16,
              child: Card(
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up),
                      tooltip: 'Previous Result',
                      onPressed: () {
                        if (_searchResult.currentInstanceIndex == 1) {
                          for (int i = 1;
                              i < _searchResult.totalInstanceCount;
                              i++) {
                            _searchResult.nextInstance();
                          }
                          setState(() {});
                        } else {
                          _searchResult.previousInstance();
                          setState(() {});
                        }
                      },
                    ),
                    Text(
                      '${_searchResult.currentInstanceIndex}/${_searchResult.totalInstanceCount}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      tooltip: 'Next Result',
                      onPressed: () {
                        if (_searchResult.currentInstanceIndex ==
                            _searchResult.totalInstanceCount) {
                          _searchResult.nextInstance();
                          setState(() {});
                        } else {
                          _searchResult.nextInstance();
                          setState(() {});
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear Search',
                      onPressed: () {
                        _searchResult.clear();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _pdfViewerController.previousPage(),
            ),
            Text('$_currentPage/$_totalPages'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _pdfViewerController.nextPage(),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () =>
                  setState(() => _pdfViewerController.zoomLevel += 0.25),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () =>
                  setState(() => _pdfViewerController.zoomLevel -= 0.25),
            ),
          ],
        ),
      ),
    );
  }
}
