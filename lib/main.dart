import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PDFBookReader(pdfAssetPath: "assets/somatosensory.pdf",),
    );
  }
}



class PDFBookReader extends StatefulWidget {
  final String pdfAssetPath;

  const PDFBookReader({super.key, required this.pdfAssetPath});

  @override
  State<PDFBookReader> createState() => _PDFBookReaderState();
}

class _PDFBookReaderState extends State<PDFBookReader> {
  late PdfControllerPinch _pdfController;
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset(widget.pdfAssetPath),
    );
    _loadTotalPages();
  }

  Future<void> _loadTotalPages() async {
    final doc = await PdfDocument.openAsset(widget.pdfAssetPath);
    setState(() {
      totalPages = doc.pagesCount;
    });
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() {
        currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TurnPageView.builder(
        itemCount: totalPages,
        useOnSwipe: true,
        onSwipe: (isTurnForward) {
          if(isTurnForward){
            _goToPage(currentPage = currentPage + 1);
          }
        },
        itemBuilder: (context, index) {
          return FutureBuilder<PdfPageImage>(
            future: PdfDocument.openAsset(widget.pdfAssetPath)
                .then((doc) => doc.getPage(index + 1))
                .then((page) async {
              final image = await page.render(
                width: page.width,
                height: page.height,
                format: PdfPageImageFormat.png,
              );
              await page.close();
              return image!;
            }),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(snapshot.data!.bytes, fit: BoxFit.contain);
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading page.'));
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }

}
