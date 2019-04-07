# evote-movie-2019-17-category-many-to-one

Part of the progressive Movie Voting website project at: https://github.com/dr-matt-smith/evote-movie-2019

The project has been refactored as follows:

- new class created `Category` in file `/src/Category.php`:

    ```php
      namespace TuDublin;
      
      class Category
      {
          private $id;
          private $title;
        
          (and public getters / setters)
    ```
    
- new Repository class for `Category`:

    ```php
      namespace TuDublin;
      
      use Mattsmithdev\PdoCrudRepo\DatabaseTableRepository;
      
      class CategoryRepository extends DatabaseTableRepository
      {
          public function __construct()
          {
              parent::__construct(__NAMESPACE__, 'Category', 'category');
          }
      }    
    ```

- SQL for creating table and 3 categories of movies:

    ```sql
        -- create the table
        create table if not exists category (
            id integer primary key AUTO_INCREMENT,
            title text
        );
        
        -- insert some data
        insert into category values (1, 'horror');
        insert into category values (2, 'romance');
        insert into category values (3, 'musical');
    ```

- new property `categoryId` added to `Movie.php` class:

    ```php
      namespace TuDublin;
      
      class Movie
      {
          private $id;
          private $title;
          private $price;
          private $categoryId;
        
          (and public getters / setters)
    ```
    
- SQL updated to add `categoryId` in DB table `movie`:

    ```sql
          -- create the table
          create table if not exists movie (
              id integer primary key AUTO_INCREMENT,
              title text,
              price float,
              categoryId integer
          );
          
          -- insert some data
          insert into movie values (1, 'Jaws', 9.99, 1);
          insert into movie values (2, 'Jaws2', 4, 1);
          insert into movie values (3, 'Mama Mia', 9.99, 2);
          insert into movie values (4, 'Forget Paris', 8, 3);
    ```
    
- new getter added to class `Movie`, to create a `CategoryRepository` object and retrieve `Category` object from DB matrching the current movie's `categoryId` value:

    ```php      
        namespace TuDublin;        
        
        class Movie
        {
            private $id;
            private $title;
            private $price;
            private $categoryId;

            public function getCategory()
            {
                $categoryRepository = new CategoryRepository();
                $category = $categoryRepository->getOneById($this->categoryId);
        
                return $category;
            }
            
          (and public getters / setters)
    ```
    
- template `_list.php` refactored to add a category column, making use of `getCategory()` method of class `Movie`:

    ```php
      <table>
          <tr>
              <th> ID </th>
              <th> title </th>
              <th> price </th>
              <th> category </th>
      
              <?php
              if($isLoggedIn):
              ?>
                  <th> &nbsp; </th>
                  <th> &nbsp; </th>
              <?php
                  endif;
              ?>
          </tr>
      
          <?php
              foreach($movies as $movie):
          ?>
      
                  <tr>
                      <td><?= $movie->getId() ?></td>
                      <td><?= $movie->getTitle() ?></td>
                      <td>&euro; <?= $movie->getPrice() ?></td>
                      <td><?= $movie->getCategory() ?></td>
    ```
    
## Edits for the New Movie / Edit Movie forms 

- we need to pass an array of **all** categories to the new movie form, `/src/AdminController.php`:

    ```php
        function newMovieForm()
        {
            $pageTitle = 'new movie';

            $categoryRepository = new CategoryRepository();
            $categories = $categoryRepository->getAll();
          
            require_once __DIR__ . '/../templates/admin/newMovieForm.php';
        }
    ```
    
- in the `/templates/admin/newMovieForm.php` we need to loop through all `Categories` to create a `<select>` HTML drop-down menu:

    ```php
      <h1>Create new movie</h1>
      
      <form
              action = "index.php"
              methop = "GET"
      >
          <input type="hidden" name="action" value="createNewMovie">
      
          <p>
              Title:
              <input name="title" id="title">
      
          <p>
              Price:
              <input name="price" id="price">
      
          <p>
              Category:
              <select name="categoryId">
                  <?php
                      foreach($categories as $category):
                  ?>
                  <option name="categoryId" value="<?= $category->getId() ?>">
                      <?= $category->getTitle() ?>
                  </option>
                  <?php
                      endforeach;
                  ?>
              </select>
    ```
    
    ![New Movie Form](/screenshots/newMovieForm.png)
    
- we need to retreive the `categoryId` and use it to create the new `Movie` object when we process the new movie form in `/src/AdminController.php`:

    ```php
      
    function createNewMovie()
    {
        $title = filter_input(INPUT_GET, 'title');
        $price = filter_input(INPUT_GET, 'price');
        $categoryId = filter_input(INPUT_GET, 'categoryId');

        ... as before ...
    }

    private function insertMovie($title, $price, $categoryId)
    {
        $movie = new Movie();
        $movie->setTitle($title);
        $movie->setPrice($price);
        $movie->setCategoryId($categoryId);

        ... as before ...
    ```
    
And we need to do the same for the EDIT movie form, e.g. `/templates/admin/editMovieForm.php`:

```php
    <h1>EDIT New Movie</h1>
    
    <form
            action="index.php"
            method="GET"
    >
    
        <input type="hidden" name="id" value="<?= $movie->getId() ?>">
    
        <input type="hidden" name="action" value="processUpdateMovie">
    
        Title:
        <input name="title" value="<?= $movie->getTitle() ?>">
    
        <p>
        Price:
        <input name="price"  value="<?= $movie->getPrice() ?>">
    
        <p>
            Category:
            <select name="categoryId">
                <?php
                foreach($categories as $category):
                    ?>
                    <option name="categoryId" value="<?= $category->getId() ?>"
                        <?php
                            if($category->getId() == $movie->getCategoryId()){
                                print 'selected';
                            }
                        ?>
                    >
                    <?= $category->getTitle() ?>
                    </option>
                <?php
                endforeach;
                ?>
            </select>
        <p>
        <input type="submit">
    </form>
```

Notice how as we loop through all the `$categories` if the current ID matches the `categoryId` of the `$movie` object then we set that drp-down menu option to `selected` in our 'sticky' (populated) edit form.