#include <gtk/gtk.h>

static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window;
    (void)user_data; // Suppress unused parameter warning

    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Hello, Embedded Linux");
    gtk_window_set_default_size(GTK_WINDOW(window), 640, 480);

    GtkWidget *label = gtk_label_new("Hello, Embedded Linux World!");
    gtk_container_add(GTK_CONTAINER(window), label);

    gtk_widget_show_all(window);
}

int main(int argc, char **argv) {
    GtkApplication *app;
    int status;

    app = gtk_application_new("com.example.GtkApp", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);

    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}