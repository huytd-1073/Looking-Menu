import UIKit

private enum ConstantFavouriteRecipeCell {
    static let idFavouriteRecipeTableCell = "FavouriteRecipeTableCell"
    static let heightFavouriteRecipeCell: CGFloat = 100
}

final class FavouriteController: UIViewController {
    @IBOutlet weak private var favouriteRecipeTableView: UITableView!
    private var listFavouriteRecipe = [Recipe]()
    private let sqlite3 = SQLiteService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configFavouriteView()
        NotificationCenter.default.addObserver(self, selector: #selector(userAddFavourite), name: Notification.Name("addFavourite"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("addFavourite"), object: nil)
    }
    
    private func configFavouriteView() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        listFavouriteRecipe = sqlite3.readTableDietFavourite()
        favouriteRecipeTableView.register(FavouriteRecipeTableCell.self,
                                          forCellReuseIdentifier: ConstantFavouriteRecipeCell.idFavouriteRecipeTableCell)
        favouriteRecipeTableView.reloadData()
    }
    
    @objc func userAddFavourite() {
        configFavouriteView()
    }
}

extension FavouriteController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return listFavouriteRecipe.count
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        ConstantFavouriteRecipeCell.heightFavouriteRecipeCell
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = favouriteRecipeTableView.dequeueReusableCell(
                withIdentifier: ConstantFavouriteRecipeCell.idFavouriteRecipeTableCell,
                for: indexPath) as? FavouriteRecipeTableCell
        else { return UITableViewCell() }
        cell.configFavouriteRecipeCell(item: listFavouriteRecipe[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = StoryBoardReference.detail.storyBoard.instantiateViewController(
                withIdentifier: IdStoryBoardViews.detailRecipeVC)
                as? DetailRecipeController else { return }
        detailVC.recipe = listFavouriteRecipe[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sqlite3.deleteDietFavourite(idDiet: listFavouriteRecipe[indexPath.row].id)
            listFavouriteRecipe.remove(at: indexPath.row)
            favouriteRecipeTableView.reloadData()
        }
    }
}
