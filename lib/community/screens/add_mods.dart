// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gonomad/core/community/constants/error.dart';
// import 'package:gonomad/core/community/constants/loader.dart';
// import 'package:gonomad/core/community/controllers/community_controller..dart';

// class AddModScreen extends ConsumerStatefulWidget {
//   final String name;
//   const AddModScreen({
//     super.key,
//     required this.name,
//   });

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _AddModScreenState();
// }

// class _AddModScreenState extends ConsumerState<AddModScreen> {

//   Set<String> uids={};
//   int ctr=0;

// void addUids(String uid){
//   setState(() {
//     uids.add(uid);
//   });
// }

// void removeUids(String uid){
//   setState(() {
//     uids.remove(uid);
//   });
// }

// void saveMods(){
//   ref.read(CommunityControllerProvider.notifier).
//   addMods(widget.name, uids.toList(), context);
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Admins'),
//         actions: [
//           InkWell(
//             onTap: () {},
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Icon(Icons.done),
//             ),
//           ),
//           //IconButton(onPressed: (){saveMods;}, icon: const  Icon(Icons.done))
//         ],
//       ),

//        body: ref.watch(getCommunityByNameProvider(widget.name)).when(data: (communty)=> ListView.builder(

//         itemCount: communty.members.length,

//         itemBuilder: (BuildContext context, int index) {
//           final member = communty.members[index];

//           return ref.watch().when(data: (user){
//             if(communty.mods.contains(member)&& ctr==0)
//             {
//               uids.add(member);
//             }
//             ctr++;

//              return CheckboxListTile(
//             value: uids.contains(user.uid),
//             onChanged: (val){
//               if(val!)
//               {
//                 addUids(user.uid);
//               }
//               else
//               {
//                 removeUids(user.uid);
//               }
//             },
//             title: Text(user.name),

//             );},

//            error: (error,StackTrace)=> ErrorText(error: error.toString()), loading: ()=> const Loader());

//         }),

//       error: (error,StackTrace)=> ErrorText(error: error.toString()),

//        loading:()=> const Loader())

//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routemaster/routemaster.dart';
import 'package:tripsathihackathon/community/constants/error.dart';
import 'package:tripsathihackathon/community/constants/loader.dart';
import 'package:tripsathihackathon/community/controller/community_controller.dart';
import 'package:tripsathihackathon/models/usermodel.dart' as model;

class AddModScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModScreen({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModScreenState();
}

class _AddModScreenState extends ConsumerState<AddModScreen> {
  Set<String> uids = {};
  int ctr = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addUids(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUids(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref
        .read(CommunityControllerProvider.notifier)
        .addMods(widget.name, uids.toList(), context);
    Routemaster.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Admins'),
        actions: [
          InkWell(
            onTap: saveMods,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.done),
            ),
          ),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (communty) => ListView.builder(
              itemCount: communty.members.length,
              itemBuilder: (BuildContext context, int index) {
                final member = communty.members[index];

                return FutureBuilder(
                  future: getUserDetails(member),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return ErrorText(error: snapshot.error.toString());
                    }
                    final userData = snapshot.data as model.User;
                    if (communty.mods.contains(member) && ctr == 0) {
                      uids.add(member);
                    }
                    ctr++;
                    return CheckboxListTile(
                      value: uids.contains(userData.uid),
                      onChanged: (val) {
                        if (val!) {
                          addUids(userData.uid);
                        } else {
                          removeUids(userData.uid);
                        }
                      },
                      title: Text(userData.username),
                    );
                  },
                );
              },
            ),
            error: (error, StackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }

  Future<model.User> getUserDetails(String userId) async {
    final currentUser = _auth.currentUser!;
    final snap = await _firestore.collection('users').doc(userId).get();
    return model.User.fromSnap(snap);
  }
}
