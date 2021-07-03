# Creating a Cron Job for adding a new post every hour
WordPress Plugin WP-crontol is installed inside wordpress site
open wordpress site
go to tools
![Screenshot1](https://github.com/hiashutosh/Project-Test/blob/master/aws-infra/wp-deploy/images/wp-crontol%20(1).png)
go to Cron Events
![Screenshot2](https://github.com/hiashutosh/Project-Test/blob/master/aws-infra/wp-deploy/images/wp-crontol%20(2).png)
Create a new cron Event
![Screenshot3](https://github.com/hiashutosh/Project-Test/blob/master/aws-infra/wp-deploy/images/wp-crontol%20(3).png)
select PHP cron event and add following script

    global $user_ID;
    $content = "some rondom Data ";
    $post_title = "New custom post NAME";
    $new_post = array(
    'post_title' => $post_title,
    'post_content' => $content,
    'post_status' => 'publish',
    'post_date' => date('Y-m-d H:i:s'),
    'post_author' => $user_ID,
    'post_type' => 'post',
    'post_category' => array(0)
    );
    $post_id = wp_insert_post($new_post);
Set recurrence to hourly