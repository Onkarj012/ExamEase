import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_app/pages/test_details_page.dart';
import 'package:ocr_app/services/text_recognition_service.dart';
import 'package:ocr_app/widgets/image_crop_widget.dart';
import 'package:ocr_app/widgets/option_editor_drawer.dart';

import '../Holders/data_holder.dart';
import '../models/question_data.dart';
import '../widgets/question_navigation_widget.dart';

class QuestionBuilderPage extends StatefulWidget {

  const QuestionBuilderPage({super.key});

  @override
  State<QuestionBuilderPage> createState() => _QuestionBuilderPageState();
}

class _QuestionBuilderPageState extends State<QuestionBuilderPage> {
  File? imageFile;
  late List<QuestionData> _questions;
  int _currentQuestionIndex = 0;
  int _currentOptionIndex = -1;
  final CropController _cropController = CropController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;
  bool _isCroppingEnabledForTextExtraction = false;
  bool _isCroppingEnabledForImageCapture = false;
  final ImagePicker _picker = ImagePicker();
  late List<TextEditingController> _textControllers;
  bool _isTextSyncInProgress = false;
  bool isEditTest = false;

  @override
  void initState() {
    isEditTest = DataHolder.currentTest!.testId != '';
    _questions = DataHolder.currentTest!.questions;
    _initializeTextControllers();
    super.initState();
  }

  void _initializeTextControllers() {
    _textControllers = [
      TextEditingController(text: _questions[_currentQuestionIndex].questionText)
        ..addListener(() {
          if (!_isTextSyncInProgress && !_isCroppingEnabledForTextExtraction) {
            _questions[_currentQuestionIndex].questionText = _textControllers[0].text;
          }
        }),
      for (int i = 0; i < _questions[_currentQuestionIndex].options.length; i++)
        TextEditingController(text: _questions[_currentQuestionIndex].options[i].optionText)
          ..addListener(() {
            if (!_isTextSyncInProgress && !_isCroppingEnabledForTextExtraction) {
              _questions[_currentQuestionIndex].options[i].optionText = _textControllers[i + 1].text;
            }
          }),
    ];
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add(QuestionData(
        questionNumber: _questions.length + 1,
      ));
      _currentQuestionIndex = _questions.length - 1;
      _initializeTextControllers();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteCurrentQuestion() {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(_currentQuestionIndex);
        for (int i = _currentQuestionIndex; i < _questions.length; i++) {
          _questions[i].questionNumber--;
        }
        _currentQuestionIndex = (_currentQuestionIndex > 0)
            ? _currentQuestionIndex - 1
            : 0;
      });
    } else {
      setState(() {
        _questions[0] = QuestionData(
          questionNumber: 1,
        );
      });
    }
    _initializeTextControllers();
  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      setState(() {
        _currentQuestionIndex = index;
        _initializeTextControllers();
      });
    }
  }

  Future<void> _onCropped(CropResult cropResult) async {
    if (cropResult is CropSuccess) {
      final Uint8List croppedImage = cropResult.croppedImage;
      final currentQuestion = _questions[_currentQuestionIndex];

      if (_isCroppingEnabledForImageCapture) {
        setState(() {
          if (_currentOptionIndex == -1) {
            currentQuestion.questionImage = croppedImage;
          } else {
            currentQuestion.options[_currentOptionIndex].image = croppedImage;
          }
        });
        _isCroppingEnabledForImageCapture = false;
      } else if (_isCroppingEnabledForTextExtraction) {
        final tempFile = File('${Directory.systemTemp.path}/cropped_image.jpg')
          ..writeAsBytesSync(croppedImage);

        final textBlocks = await TextRecognitionService.extractTextBlocks(tempFile);
        final extractedText = textBlocks.map((block) => block.text).join(' ');

        if (extractedText.isNotEmpty) {
          setState(() {
            _isTextSyncInProgress = true;
            if (_currentOptionIndex == -1) {
              currentQuestion.questionText = extractedText;
              _textControllers[0].text = extractedText;
            } else {
              currentQuestion.options[_currentOptionIndex].optionText = extractedText;
              _textControllers[_currentOptionIndex+1].text = extractedText;
            }
            _isTextSyncInProgress = false;
          });
        } else {
          Fluttertoast.showToast(
            msg: "Try to select and maximize the area to extract text",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
        _isCroppingEnabledForTextExtraction = false;
      }
    }
    _currentOptionIndex = -1;
    setState(() => _isProcessing = false);
  }

  void _onCaptureImage(int optionIndex) {
    final currentQuestion = _questions[_currentQuestionIndex];

    if (optionIndex == -1) {
      if (currentQuestion.questionImage != null) {
        setState(() {
          currentQuestion.questionImage = null;
        });
      } else {
        _currentOptionIndex = optionIndex;
        setState(() {
          _isProcessing = true;
          _isCroppingEnabledForImageCapture = true;
          _cropController.crop();
        });
      }
    } else {
      final currentOption = currentQuestion.options[optionIndex];

      if (currentOption.image != null) {
        setState(() {
          currentOption.image = null;
        });
      } else {
        _currentOptionIndex = optionIndex;
        setState(() {
          _isProcessing = true;
          _isCroppingEnabledForImageCapture = true;
          _cropController.crop();
        });
      }
    }
  }

  void _onExtractText(int optionIndex) {
    _currentOptionIndex = optionIndex;
    setState(() {
      _isProcessing = true;
      _isCroppingEnabledForTextExtraction = true;
      _cropController.crop();
    });
  }

  void _onSave() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestDetailsPage(),
      ),
    );
  }

  void _onSetCorrectOption(int value) {
    setState(() {
      _questions[_currentQuestionIndex].correctOptionIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 25),
                      Text(
                        isEditTest ? 'Edit Test' : 'Create Test',
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.done),
                    tooltip: 'Save Test',
                    onPressed: _onSave,
                  ),
                ],
              ),
            ),
            // Body Content
            QuestionNavigationPanel(
              currentQuestionIndex: _currentQuestionIndex,
              questions: List.generate(_questions.length, (index) => 'Q${index + 1}'),
              onNavigateToQuestion: _navigateToQuestion,
              onAddNewQuestion: _addNewQuestion,
              scrollController: _scrollController,
            ),
            Expanded(
              child: Stack(
                children: [
                  (imageFile != null)
                      ? ImageCropWidget(
                    imageBytes: imageFile!.readAsBytesSync(),
                    cropController: _cropController,
                    onCropped: _onCropped,
                    isProcessing: _isProcessing,
                  )
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _getImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A1D37),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Capture Image'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _getImage(ImageSource.gallery),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A1D37),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Pick from Gallery'),
                        ),
                      ],
                    ),
                  ),
                  OptionEditorDrawer(
                      textControllers: _textControllers,
                      images: [
                        currentQuestion.questionImage,
                        ...currentQuestion.options.map((o) => o.image),
                      ],
                      onSelectTextCallbacks: List.generate(
                        5,
                            (i) => () => _onExtractText(i - 1),
                      ),
                      onCaptureImageCallbacks: List.generate(
                        5,
                            (i) => () => _onCaptureImage(i - 1),
                      ),
                      onTextChangedCallbacks: [
                            (newText) {
                          setState(() {
                            currentQuestion.questionText = newText;
                          });
                        },
                        ...List.generate(currentQuestion.options.length, (i) {
                          return (newText) {
                            setState(() {
                              currentQuestion.options[i].optionText = newText;
                            });
                          };
                        }),
                      ],
                      questionIndex: _currentQuestionIndex,
                      correctOptionIndex: currentQuestion.correctOptionIndex,
                      onSetCorrectOption: _onSetCorrectOption,
                      deleteCurrentQuestion: _deleteCurrentQuestion
                  ),
                  if (imageFile != null)
                    ElevatedButton(
                      onPressed: () => {
                        setState(() {
                          imageFile = null;
                        })
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1D37),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Remove Image'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}