import 'package:chat_room/consts.dart';
import 'package:chat_room/services/themeDataService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_room/components/groupSearchQueryTile.dart';

class SearchGroupsScreen extends StatefulWidget {
  const SearchGroupsScreen({Key? key}) : super(key: key);
  static String id = "search_groups_screen";
  @override
  State<SearchGroupsScreen> createState() => _SearchGroupsScreenState();
}

class _SearchGroupsScreenState extends State<SearchGroupsScreen> {
  TextEditingController searchController = TextEditingController();
  final _fireStore = FirebaseFirestore.instance;
  String query = "";
  QuerySnapshot? querySnapshot;
  bool hasUserSearched = false;
  bool noResults = false;
  List<Map> allGroups = [];
  List<GroupSearchQueryTile> showGrpTiles = [];
  bool isLocalListLoading = true;
  MainScreenTheme themeData = MainScreenTheme();

  @override
  void initState() {
    super.initState();
    themeData.addListener(themeListener);
    fetchAllGroups();
  }

  @override
  void dispose() {
    super.dispose();
    themeData.removeListener(themeListener);
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }


  fetchAllGroups()async{
    QuerySnapshot snapshot =  await _fireStore.collection("groups").get();
    for(var doc in snapshot.docs){
     try{
       String groupName = doc.get("name");
       String groupId = doc.get("groupId");
       if(groupName.isNotEmpty&&groupId.isNotEmpty) {
         allGroups.add({
           "grpName": groupName,
           "grpId": groupId
         });
       }
     }catch(e){
       continue;
     }
    }
    setState(() {
      isLocalListLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainScreenTheme.mainScreenBg,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        elevation: 0,
        title: Text("Search",style: GoogleFonts.poppins(color: Colors.white,fontSize: 27,fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                child: TextField(
                  keyboardType: TextInputType.name,
                    onChanged: (val){
                    setState(() {
                      query = val;
                    });
                    localSearchGroup(val.trim());
                    },
                  onSubmitted: (val){
                    localSearchGroup(val.trim());
                  },
                  cursorColor: Colors.white,
                  controller: searchController,
                  style: GoogleFonts.poppins(color:Colors.white),
                  decoration: kSearchGroupInputDecoration.copyWith(
                    suffixIcon: IconButton(icon: const Icon(Icons.search,color: Colors.white,),
                      onPressed: () {
                        localSearchGroup(query.trim());
                      },
                    )
                  )
                ),
            ),
            const SizedBox(height: 10,),
            isLocalListLoading ? Center(child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.25,),
                const CircularProgressIndicator(color: Colors.white,),
                const SizedBox(height: 20,),
                Text("fetching groups..",style:GoogleFonts.poppins(color:Colors.white ))
              ],
            ),) : localListGroupTile()
          ],
        ),
      ),
    );
  }

  localListGroupTile(){
    if(hasUserSearched && !noResults){
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: showGrpTiles.length,
        itemBuilder: (context,index){
          return showGrpTiles[index];
        },
      );
    }
    else if(noResults){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.25,),
            const Icon(Icons.not_interested_outlined,color: Colors.white12,size: 100,),
            Text("No search results found",style: GoogleFonts.poppins(color: Colors.white12,fontSize: 20),),
          ],
        ),
      );
    }
    else if (!hasUserSearched){
      //can be updated with new hot groups right now plan
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.25,),
            const Icon(Icons.search,color: Colors.white12,size: 100,),
            Text("Search for results",style: GoogleFonts.poppins(color: Colors.white12,fontSize: 20),)
          ],
        ),
      );
    }
  }

  void localSearchGroup(String query){
    if(searchController.text.trim().isEmpty){
      showGrpTiles = [];
      setState(() {
        hasUserSearched = false;
        noResults = false;
      });
    } else{
      setState(() {
        hasUserSearched = true;
        noResults = false;
      });
      if(query == "/*all"){
        List<GroupSearchQueryTile> localQueryList = [];
        for(var grp in allGroups){
          localQueryList.add(GroupSearchQueryTile(groupId: grp["grpId"]));
        }
        setState(() {
          showGrpTiles = localQueryList;
        });
      }else{
        List grpList = allGroups.where((grp){
          final grpName = grp["grpName"].toString().toLowerCase().trim();
          final input = query.toLowerCase();
          if(input[0] == grpName[0]){
            if(query.length > 3){
              if(input == grpName.substring(0,input.length)){
                return grpName.contains(input);
              }
              else{
                return false;
              }
            }
            else{
              return grpName.contains(input);
            }
          }
          else{
            return false;
          }
        }
        ).toList();
        if(grpList.isEmpty){
          setState(() {
            noResults = true;
          });
        }
        List<GroupSearchQueryTile> localQueryList = [];
        for(var grp in grpList){
          localQueryList.add(GroupSearchQueryTile(groupId: grp["grpId"]));
        }
        setState(() {
          showGrpTiles = localQueryList;
        }
        );
      }
    }
  }
}
