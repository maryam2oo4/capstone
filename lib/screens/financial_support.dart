import 'package:flutter/material.dart';
import 'supportform.dart';
import 'app_drawer.dart';

class FinancialSupportPage extends StatefulWidget {
  const FinancialSupportPage({super.key});

  @override
  State<FinancialSupportPage> createState() => _FinancialSupportPageState();
}

class _FinancialSupportPageState extends State<FinancialSupportPage> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _formKey = GlobalKey();
  final GlobalKey _patientCardsKey = GlobalKey();
  int _currentPage = 0;
  String _selectedPatientName = '';

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollRight() {
    if (_currentPage < patients.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Patient data - admin can easily add more cases here
  final List<Map<String, dynamic>> patients = [
    {
      'name': 'Ali, 12',
      'title': 'Kidney Transplant',
      'description':
          'Ahmed has been on dialysis for 2 years and urgently needs a kidney transplant. His family cannot afford the surgery costs.',
      'raised': 8500,
      'goal': 25000,
      'image': 'assets/images/articlepic.png',
    },
    {
      'name': 'Maya, 28',
      'title': 'Heart Surgery',
      'description':
          'Maya needs urgent heart surgery. She has no insurance and her family is struggling to cover the medical bills.',
      'raised': 12000,
      'goal': 35000,
      'image': 'assets/images/articlepic.png',
    },
    {
      'name': 'Omar, 45',
      'title': 'Cancer Treatment',
      'description':
          'Omar is undergoing chemotherapy for cancer. He needs financial support for ongoing treatment and medication.',
      'raised': 5500,
      'goal': 20000,
      'image': 'assets/images/articlepic.png',
    },
    {
      'name': 'Fatima, 8',
      'title': 'Brain Surgery',
      'description':
          'Fatima needs emergency brain surgery. Time is critical and her parents need immediate financial support.',
      'raised': 15000,
      'goal': 40000,
      'image': 'assets/images/articlepic.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Financial Support'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Photo placed at the top
              PhotoCard(
                imagePath: 'assets/images/articlepic.png',
                label: 'Support Patients \n Save Lives.',
                width: double.infinity,
                height: 200,
              ),
              SizedBox(height: 20),
              // Shadowed container placed after the PhotoCard
              Container(
                width: double.infinity,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Why Your Support Matters',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 42, 59, 68),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Many patients struggle with the high cost of surgeries, transplants, and treatments. With your support, you can directly ease their burden and give them a chance at recovery.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2F72FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Surgery Costs',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Helps cover expensive surgical procedures and hospital stays',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Color(0xFF00C17F),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Essential Medicines',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Funds critical medications and ongoing treatments',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Color(0xFF7B4CFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Hospital Care',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Supports extended hospital care and specialized treatments',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // How It Works card
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'How It Works',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF2F72FF),
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Choose Support',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Select a specific patient to help or contribute to urgent cases',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF2F72FF),
                                child: Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Donate Securely',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Choose amount and a secure payment method',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF2F72FF),
                                child: Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Track Impact',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Receive updates on how your funds are used',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Patients Who Need Your Help
              Container(
                key: _patientCardsKey,
                width: double.infinity,
                margin: EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patients Who Need Your Help',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                            size: 24,
                          ),
                          onPressed: _scrollLeft,
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final screenWidth = MediaQuery.of(
                                context,
                              ).size.width;
                              // Card width = full available width (screen - padding - arrows)
                              final double cardWidth = (screenWidth - 32 - 96)
                                  .clamp(240.0, 340.0);
                              return SizedBox(
                                height: 400,
                                child: PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPage = index;
                                    });
                                  },
                                  itemCount: patients.length,
                                  itemBuilder: (context, index) {
                                    final patient = patients[index];
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: PatientCard(
                                        imagePath: patient['image'],
                                        name: patient['name'],
                                        title: patient['title'],
                                        description: patient['description'],
                                        raised: patient['raised'],
                                        goal: patient['goal'],
                                        onSupport: () {
                                          // Update the form's selected patient
                                          setState(() {
                                            _selectedPatientName =
                                                patient['name'].split(',')[0];
                                          });
                                          // Scroll back to the Choose Recipient section of the form
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                final RenderObject?
                                                renderObject = _formKey
                                                    .currentContext
                                                    ?.findRenderObject();
                                                if (renderObject is RenderBox) {
                                                  final offset = renderObject
                                                      .localToGlobal(
                                                        Offset.zero,
                                                      )
                                                      .dy;
                                                  _scrollController.animateTo(
                                                    _scrollController.offset +
                                                        offset +
                                                        300,
                                                    duration: Duration(
                                                      milliseconds: 500,
                                                    ),
                                                    curve: Curves.easeInOut,
                                                  );
                                                }
                                              });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 24,
                          ),
                          onPressed: _scrollRight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SupportFormContent(
                key: _formKey,
                patientName: patients[_currentPage]['name'].split(',')[0],
                selectedPatientName: _selectedPatientName,
                onSelectSpecificPatient: () {
                  // Scroll to patient cards when "Specific Patient" is selected
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final RenderObject? renderObject = _patientCardsKey
                        .currentContext
                        ?.findRenderObject();
                    if (renderObject is RenderBox) {
                      final offset = renderObject.localToGlobal(Offset.zero).dy;
                      _scrollController.animateTo(
                        _scrollController.offset + offset - 100,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhotoCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final double width;
  final double height;

  const PhotoCard({
    super.key,
    required this.imagePath,
    required this.label,
    this.width = 300,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
            ),
            Container(color: Colors.black26),
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String title;
  final String description;
  final num raised;
  final num goal;
  final VoidCallback onSupport;

  const PatientCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.title,
    required this.description,
    required this.raised,
    required this.goal,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final double progressValue = (goal.toDouble() > 0)
        ? (raised.toDouble() / goal.toDouble()).clamp(0.0, 1.0)
        : 0.0;
    final String percentFunded =
        '${(progressValue * 100).toStringAsFixed(1)}% funded';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  Container(height: 150, color: Colors.grey[300]),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10),
                // Raised/Goal row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Raised: \$${raised.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Goal: \$${goal.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00C17F),
                    ),
                  ),
                ),
                SizedBox(height: 6),
                // Percentage funded text
                Text(
                  percentFunded,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00C17F),
                  ),
                ),
                SizedBox(height: 10),
                // Support button
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E4FB8), Color(0xFF2F72FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onSupport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
