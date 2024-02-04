import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:go_dutch/group_chats/group_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: unused_import, import_of_legacy_library_into_null_safe
import 'package:flutter_smart_reply/flutter_smart_reply.dart';
import 'package:uuid/uuid.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName;
  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);
  @override
  State<GroupChatRoom> createState() => _GroupChatRoom();
}

class _GroupChatRoom extends State<GroupChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //variables

  // a list to track what text messages are added.
  List<TextMessage> _textMessages = [];

  // a list to sotre suggested reply messages.
  List<String> _replies = List.empty();

  // whether the message is from local side or remote side
  bool isSelfMode = true;

  // when _textMessages are updated, we call this function to update the suggested replies.
  Future<void> updateSmartReplies() async {
    try {
      //it will be empty till you dont add the message from remote side ok!!! so for now it's working fine
      //print text messages
      // for (int i = 0; i < _textMessages.length; i++) {
      //   // Fluttertoast.showToast(
      //   //     msg: _textMessages[i].text +
      //   //         _textMessages[i].timestamp.toString() +
      //   //         _textMessages[i].isSelf.toString());
      // }
      List<String> oldReplies = _replies;
      _replies = await FlutterSmartReply.getSmartReplies(_textMessages);
      if (!listEquals(_replies, oldReplies)) {
        setState(() {});
      }
      // ignore: nullable_type_in_catch_clause
    } on PlatformException {}
  }

  Widget _buildSmartReplyRow() {
    return Container(
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment:
            isSelfMode ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [_buildSmartReplyChips()],
      ),
    );
  }

  Widget _buildSmartReplyChips() => ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: _replies.map(_buildSmartReplyChip).toList(),
      );

  Widget _buildSmartReplyChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () => {_message.text = text, onSendMessage()},
    );
  }

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        //   Fluttertoast.showToast(msg: xFile.toString());
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": DateTime.now(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();
      // Fluttertoast.showToast(msg: "OH HO STATUS 0");
      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      // Fluttertoast.showToast(msg: "YES IMAGE URL IS " + imageUrl);
      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": DateTime.now(),
      };
      // Fluttertoast.showToast(msg: isSelfMode.toString());
      // _textMessages.add(isSelfMode
      //     ? TextMessage.createForLocalUser(
      //         _message.text.toString(), DateTime.now().millisecondsSinceEpoch)
      //     : TextMessage.createForRemoteUser(
      //         _message.text.toString(), DateTime.now().millisecondsSinceEpoch));

      // await updateSmartReplies();

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupInfo(
                        groupName: widget.groupName,
                        groupId: widget.groupChatId,
                      ),
                    ),
                  ),
              icon: Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.5,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('groups')
                    .doc(widget.groupChatId)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _textMessages.clear();
                    //whatever the data we get from snapshot is on the conversation screen
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> chatMap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;

                        if (chatMap['sendBy'].toString() ==
                            _auth.currentUser!.displayName) {
                          //if the message is sent rn so chatMap will be null so just checking

                          if (chatMap['time'] == null) {
                            chatMap['time'] = DateTime.now();
                          }

                          _textMessages.add(TextMessage.createForLocalUser(
                              chatMap['message'].toString(),
                              chatMap['time'].millisecondsSinceEpoch));
                        } else {
                          _textMessages.add(TextMessage.createForRemoteUser(
                              chatMap['message'].toString(),
                              chatMap['time'].millisecondsSinceEpoch));
                        }
                        //now the text messages are ready
                        //we will pass them to update replies
                        //and the update replies will compare new suggestion with the old suggestions
                        //if we have some new suggestion we will set the state
                        if (index == snapshot.data!.docs.length - 1) {
                          updateSmartReplies();
                        }
                        debugPrint("Index is " +
                            index.toString() +
                            chatMap['type'].toString());

                        return messageTile(size, chatMap);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            _buildSmartReplyRow(),
            //this is not in loop replies are getting updated but this is not
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 17,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () => getImage(),
                              icon: Icon(Icons.photo),
                            ),
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.send), onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      debugPrint("type is :");
      debugPrint(chatMap['type']);
      if (chatMap['type'] == "text") {
        debugPrint("text type");

        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  Text(
                    chatMap['sendBy'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height / 200,
                  ),
                  Text(
                    chatMap['message'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          height: size.height / 2.5,
          width: size.width,
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          alignment: chatMap['sendby'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShowImage(
                  imageUrl: chatMap['message'],
                ),
              ),
            ),
            child: Container(
              height: size.height / 2.5,
              width: size.width / 2,
              decoration: BoxDecoration(border: Border.all()),
              alignment: chatMap['message'] != "" ? null : Alignment.center,
              child: chatMap['message'] != ""
                  ? Image.network(
                      chatMap['message'],
                      fit: BoxFit.cover,
                    )
                  : CircularProgressIndicator(),
            ),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        debugPrint("notify received");

        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}

//
