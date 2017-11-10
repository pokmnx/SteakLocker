<?php
require_once ('_includes/page_header.php');
?>


    <div id="page-wrapper">

        <div class="container-fluid">
            <h1>Search Users</h1>
            <form class="form-inline" onsubmit="return SL.searchUsers(this)">
                <div class="form-group">
                    <label for="search-field">Search By: </label>
                    <select class="form-control" id="search-field">
                        <option value="email">Email</option>
                        <option value="name">Name</option>
                    </select>
                </div>
                <div class="form-group">
                    <input type="text" size="30" class="form-control" id="search-value" placeholder="" value="">
                </div>
                <button type="submit" class="btn btn-primary" data-text="Search" data-icon="fa-search" data-working-text="Searching..." data-working-icon="fa-refresh fa-spin"><i class="fa fa-fw fa-search"></i> <span class="text">Search</span></button>
            </form>



            <table id="results" class="table table-striped">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Pro User</th>
                </tr>
                </thead>
                <tbody>

                </tbody>

            </table>
        </div>



        <!-- /.container-fluid -->

    </div>
    <!-- /#page-wrapper -->



    <script type="text/template" id="tpl-user-row">
        <tr>
            <td><a href="user?id=<%= objectId %>"><%= objectId %></a></td>
            <td><%= name %></td>
            <td><%= email %></td>
            <td><% if (typeof(isProUser) != 'undefined' && isProUser) { %>Yes<% } else { } %></td>
        </tr>
    </script>

    <script type="text/template" id="tpl-no-results">
        <tr>
            <td colspan="4" align="center">No results for '<%-query%>'.</td>
        </tr>
    </script>


<?php
require_once ('_includes/page_footer.php');
?>