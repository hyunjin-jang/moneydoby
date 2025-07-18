drop function if exists public.handle_new_user() CASCADE;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
begin
    if new.raw_app_meta_data is not null then
        if new.raw_app_meta_data ? 'provider' AND new.raw_app_meta_data ->> 'provider' = 'email' then
            if new.raw_user_meta_data ? 'name' and new.raw_user_meta_data ? 'username' then
                insert into public.profiles (id, name, username, role)
                values (new.id, new.raw_user_meta_data ->> 'name', new.raw_user_meta_data ->> 'username', 'user');
            else
                insert into public.profiles (id, name, username, role)
                values (new.id, 'Anonymous', 'mr.' || substr(md5(random()::text), 1, 8), 'user');
            end if;
        end if;
    end if;
    return new;
end;
$$;

drop trigger if exists user_to_profile_trigger on auth.users;

create trigger user_to_profile_trigger
after insert on auth.users
for each row execute function public.handle_new_user();
