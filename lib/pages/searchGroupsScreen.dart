import 'package:chat_room/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_room/components/groupSearchQueryTile.dart';
import 'package:hexcolor/hexcolor.dart';


class SearchGroupsScreen extends StatefulWidget {
  const SearchGroupsScreen({Key? key}) : super(key: key);
  static String id = "search_groups_screen";
  @override
  State<SearchGroupsScreen> createState() => _SearchGroupsScreenState();
}

class _SearchGroupsScreenState extends State<SearchGroupsScreen> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  final _fireStore = FirebaseFirestore.instance;
  String query = "";
  QuerySnapshot? querySnapshot;
  int snapshotDocsLen = 0;
  bool hasUserSearched = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                  },
                  onSubmitted: (val){
                    initiateSearchGroup();
                  },
                  cursorColor: Colors.white,
                  controller: searchController,
                  style: GoogleFonts.poppins(color:Colors.white),
                  decoration: kSearchGroupInputDecoration.copyWith(
                    suffixIcon: IconButton(icon: const Icon(Icons.search,color: Colors.white,),
                      onPressed: () {
                        initiateSearchGroup();
                      },
                    )
                  )
                ),
            ),
            const SizedBox(height: 10,),
            isLoading ? Center(child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.25,),
                const CircularProgressIndicator(color: Colors.white,),
              ],
            ),) : groupList()
          ],
        ),
      ),
    );
  }
  initiateSearchGroup()async{
    if(searchController.text.isNotEmpty){
      setState(() {
        isLoading = true;
      });
      await _fireStore.collection("groups").where("name",isEqualTo: query).get().then((snapshot){
        setState(() {
          querySnapshot = snapshot;
          snapshotDocsLen = snapshot.docs.length;
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  groupList(){
    return hasUserSearched && snapshotDocsLen > 0?
    ListView.builder(
        shrinkWrap: true,
        itemCount: querySnapshot?.docs.length,
        itemBuilder: (context,index){
            return GroupSearchQueryTile(groupId: querySnapshot?.docs[index]["groupId"],);
        },
    )
        : Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.25,),
          !hasUserSearched ?
          Icon(Icons.search,color: HexColor("222222"),size: 100,):
          Icon(Icons.not_interested_outlined,color: HexColor("222222"),size: 100,),
          !hasUserSearched ?
          Text("Search for results",style: GoogleFonts.poppins(color: HexColor("222222"),fontSize: 20),) :
          Text("No search results found",style: GoogleFonts.poppins(color: HexColor("222222"),fontSize: 20),)
        ],
      ),
    );
  }

}
