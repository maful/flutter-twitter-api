import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_twitter_api/config_reader.dart';
import 'package:riverpod_twitter_api/controllers/twitter_controller.dart';
import 'package:riverpod_twitter_api/repositories/twitter_repository.dart';

Future<void> main() async {
  // Always call this if the main method is asynchronous
  WidgetsFlutterBinding.ensureInitialized();
  // Load the JSON config into memory
  await ConfigReader.initialize();

  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final tweetTextEditingController = useTextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFE9EFFD),
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Calm tweeter',
                style: Theme.of(context).textTheme.headline4.copyWith(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(top: kToolbarHeight * 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(42),
                topRight: Radius.circular(42),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Spacer(),
                TweetResponse(),
                Spacer(),
                CustomInputField(
                  onPressed: () =>
                      postTweet(context, tweetTextEditingController),
                  textEditingController: tweetTextEditingController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void postTweet(BuildContext context,
      TextEditingController tweetTextEditingController) async {
    if (tweetTextEditingController.text.isEmpty) return;

    final result = await context
        .read(twitterControllerProvider)
        .postTweet(tweetTextEditingController.text);
    if (result.isRight()) {
      tweetTextEditingController.clear();
    }
  }
}

class CustomInputField extends StatelessWidget {
  const CustomInputField({
    Key key,
    @required this.textEditingController,
    @required this.onPressed,
  }) : super(key: key);

  final TextEditingController textEditingController;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 4,
      maxLength: 280,
      maxLengthEnforced: true,
      decoration: InputDecoration(
        hintText: 'How are you all doing?',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: ClipOval(
          child: Material(
            color: Colors.white.withOpacity(0.0),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(Icons.send),
            ),
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF6F8FD),
      ),
    );
  }
}

class TweetResponse extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final tweetControllerState = useProvider(twitterControllerProvider.state);
    final theme = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: const Color(0xFF2F3A5D));

    return tweetControllerState.when(
      data: (data) => Text(
        data.isEmpty ? 'Write a tweet' : 'Tweet: $data',
        style: theme,
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, sr) {
        if (err is Failure) {
          return Text(err.message, style: theme);
        }
        return Text('An unexpected error occured', style: theme);
      },
    );
  }
}
