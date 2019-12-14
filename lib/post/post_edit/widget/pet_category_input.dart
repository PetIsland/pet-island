part of petisland.post.post_edit.widget;

class PetCategoryInput extends TStatelessWidget {
  final List<PetCategory> categories = DI.get<AuthenticationBloc>(AuthenticationBloc).categories;
  final PostEditBloc bloc;

  PetCategoryInput(this.bloc) {
    if (bloc.petCategory == null) {
      bloc.petCategory = categories.isNotEmpty ? categories.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.only(left: 13, right: 5),
        child: Flex(
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: <Widget>[
            Text(
              'Chủng loại',
              style: TTextStyles.semi(
                fontSize: 18,
              ).copyWith(
                fontFamily: FontFamilies.thabit,
              ),
            ),
            SizedBox(height: 5),
            TDropDown.builder(
              initSelectedItem: categories.indexWhere(
                  (petCategory) => bloc.petCategory.id == petCategory.id),
              itemCount: categories.length,
              onSelectedChanged: _onSelectedChanged,
              builder: (_, int index) {
                final PetCategory petCategory = categories[index];
                return Text(petCategory.name);
              },
            )
          ],
        ),
      ),
    );
  }

  void _onSelectedChanged(int index) {
    final PetCategory petCategory = categories[index];
    bloc.petCategory = petCategory;
  }
}