test_that("custom slider works", {


  testthat::expect_equal(countryInput("id", "country"), "<div class='form-group shiny-input-container'>
                           <label class='control-label' for='id'>
                           <h4 style='color:navy'>Select Country</h4>
                           </label>
                           <div>
                           <select id='id'><option value='country'>country</option></select>
                           <script type='application/json' data-for='id' data-nonempty=''>{}</script>
                           </div>
                           </div>")
})
